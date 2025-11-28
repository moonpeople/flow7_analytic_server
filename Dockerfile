# ---- Build stage ----
FROM elixir:1.19.3-alpine AS build

# Устанавливаем необходимые пакеты для сборки
RUN apk add --no-cache \
    build-base git curl bash nodejs npm openssl ncurses-libs libgcc libstdc++ ca-certificates \
    && update-ca-certificates

WORKDIR /app
ENV MIX_ENV=prod

# Hex и Rebar
RUN mix local.hex --force && mix local.rebar --force

# --- Кэширование зависимостей ---
COPY mix.exs mix.lock ./
COPY config config

RUN mix deps.get --only prod
RUN mix deps.compile

# --- Копируем исходники и компилируем проект ---
COPY lib lib
COPY priv priv

RUN mix compile
RUN mix release

# ---- Runtime stage ----
FROM elixir:1.19.3-alpine AS runner

WORKDIR /app
ENV MIX_ENV=prod
ENV PORT=4000

# Минимальные библиотеки для Beam
RUN apk add --no-cache openssl ncurses-libs libgcc libstdc++ ca-certificates \
    && update-ca-certificates

# Копируем релиз из build stage
COPY --from=build /app/_build/prod/rel/flow7_analytic_server ./

EXPOSE 4000

CMD ["bin/flow7_analytic_server", "start"]
