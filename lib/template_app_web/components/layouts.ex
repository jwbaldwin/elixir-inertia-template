defmodule TemplateAppWeb.Layouts do
  @moduledoc """
  Root HTML, asset tags, and shared page layouts
  """
  use TemplateAppWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates("layouts/*")

  @doc """
  Renders Vite asset tags. In dev, points to the Vite dev server.
  In prod, reads the Vite manifest for fingerprinted filenames.
  """
  if Mix.env() == :dev do
    def vite_tags(assigns) do
      ~H"""
      <script phx-no-curly-interpolation type="module">
        import RefreshRuntime from "http://localhost:5173/@react-refresh"
        RefreshRuntime.injectIntoGlobalHook(window)
        window.$RefreshReg$ = () => {}
        window.$RefreshSig$ = () => (type) => type
        window.__vite_plugin_react_preamble_installed__ = true
      </script>
      <script type="module" src="http://localhost:5173/@vite/client">
      </script>
      <script type="module" src="http://localhost:5173/js/app.tsx">
      </script>
      """
    end
  else
    @manifest_path Path.join([
                     :code.priv_dir(:template_app),
                     "static",
                     "assets",
                     ".vite",
                     "manifest.json"
                   ])

    @external_resource @manifest_path

    if File.exists?(@manifest_path) do
      @manifest @manifest_path |> File.read!() |> Jason.decode!()
    else
      @manifest %{}
    end

    def vite_tags(assigns) do
      js_file = get_in(@manifest, ["js/app.tsx", "file"])
      css_files = get_in(@manifest, ["js/app.tsx", "css"]) || []

      assigns = assign(assigns, js_file: js_file, css_files: css_files)

      ~H"""
      <link :for={css_file <- @css_files} rel="stylesheet" href={"/assets/#{css_file}"} />
      <script :if={@js_file} type="module" defer phx-track-static src={"/assets/#{@js_file}"}>
      </script>
      """
    end
  end

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  attr(:current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"
  )

  slot(:inner_block, required: true)

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end
end
