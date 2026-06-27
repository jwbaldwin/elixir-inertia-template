ARG ELIXIR_VERSION=1.19.4
ARG OTP_VERSION=28.3.2
ARG DEBIAN_VERSION=bookworm-20260202-slim
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS build

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends build-essential curl unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://bun.sh/install | bash

ENV BUN_INSTALL=/root/.bun
ENV PATH=${BUN_INSTALL}/bin:${PATH}

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

COPY assets/package.json assets/bun.lock assets/
RUN bun install --cwd assets --frozen-lockfile

COPY assets assets
COPY priv priv
COPY lib lib

RUN mix assets.deploy
RUN mix compile
RUN mix release

FROM ${RUNNER_IMAGE} AS runtime

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN useradd --system --home-dir /app --shell /usr/sbin/nologin app

COPY --from=build --chown=app:app /app/_build/prod/rel/template_app ./

USER app

ENV PHX_SERVER=true
ENV PORT=4000

EXPOSE 4000

CMD ["bin/template_app", "start"]
