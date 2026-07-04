package server

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"

	"github.com/bufbuild/connect-go"
	"github.com/jackc/pgx/v5/pgxpool"
	pbv1connect "github.com/kshku/findiary/backend/internal/api/findiary/v1/v1connect"
	"github.com/kshku/findiary/backend/internal/api"
	"github.com/kshku/findiary/backend/internal/config"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/kshku/findiary/backend/pkg/jwt"
)

type Server struct {
	cfg    *config.Config
	logger *slog.Logger
	db     *pgxpool.Pool
	jwtMgr *jwt.Manager
	mux    *http.ServeMux
}

func New(cfg *config.Config, logger *slog.Logger) (*Server, error) {
	db, err := pgxpool.New(context.Background(), cfg.Database.DSN())
	if err != nil {
		return nil, fmt.Errorf("connect to database: %w", err)
	}

	mgr := jwt.NewManager(cfg.JWT.Secret, cfg.JWT.AccessTTL, cfg.JWT.RefreshTTL)

	userRepo := repository.NewUserRepo(db)
	familyRepo := repository.NewFamilyRepo(db)
	categoryRepo := repository.NewCategoryRepo(db)
	txRepo := repository.NewTransactionRepo(db)

	authSvc := service.NewAuthService(userRepo, mgr)
	familySvc := service.NewFamilyService(familyRepo, userRepo)
	categorySvc := service.NewCategoryService(categoryRepo, familyRepo)
	txSvc := service.NewTransactionService(txRepo, categoryRepo, familyRepo)

	authHandler := api.NewAuthHandler(authSvc)
	familyHandler := api.NewFamilyHandler(familySvc)
	categoryHandler := api.NewCategoryHandler(categorySvc)
	txHandler := api.NewTransactionHandler(txSvc)

	mux := http.NewServeMux()

	authPattern, authHTTPHandler := pbv1connect.NewAuthServiceHandler(
		authHandler,
		connect.WithInterceptors(
			LoggingInterceptor(logger),
			AuthInterceptor(mgr),
		),
	)
	mux.Handle(authPattern, authHTTPHandler)

	familyPattern, familyHTTPHandler := pbv1connect.NewFamilyServiceHandler(
		familyHandler,
		connect.WithInterceptors(
			LoggingInterceptor(logger),
			AuthInterceptor(mgr),
		),
	)
	mux.Handle(familyPattern, familyHTTPHandler)

	categoryPattern, categoryHTTPHandler := pbv1connect.NewCategoryServiceHandler(
		categoryHandler,
		connect.WithInterceptors(
			LoggingInterceptor(logger),
			AuthInterceptor(mgr),
		),
	)
	mux.Handle(categoryPattern, categoryHTTPHandler)

	txPattern, txHTTPHandler := pbv1connect.NewTransactionServiceHandler(
		txHandler,
		connect.WithInterceptors(
			LoggingInterceptor(logger),
			AuthInterceptor(mgr),
		),
	)
	mux.Handle(txPattern, txHTTPHandler)

	return &Server{
		cfg:    cfg,
		logger: logger,
		db:     db,
		jwtMgr: mgr,
		mux:    mux,
	}, nil
}

func (s *Server) Start() error {
	addr := s.cfg.Server.Address()
	s.logger.Info("starting server", "address", addr)
	return http.ListenAndServe(addr, s.mux)
}

func (s *Server) Shutdown(ctx context.Context) error {
	s.db.Close()
	return nil
}
