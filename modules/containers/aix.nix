{ config, lib, pkgs, ... }:

let
  cfg = config.modules.containers.ai;
in
{
  options = {
    modules = {
      containers = {
        ai = {
          enable = lib.mkEnableOption "Local AI Stack (Llama.cpp ROCm + OpenWebUI)";

          modelPath = lib.mkOption {
            type = lib.types.path;
            description = "Directory on the host containing your .gguf model files.";
            default = "/home/joe/models";
          };

          modelName = lib.mkOption {
            type = lib.types.str;
            default = "qwen2.5-coder-32b-instruct-q8_0.gguf";
            description = "The specific .gguf filename to load.";
          };

          contextSize = lib.mkOption {
            type = lib.types.int;
            default = 32768;
            description = "Context window size.";
          };

          openWebUiPort = lib.mkOption {
            type = lib.types.port;
            default = 3000;
            description = "External port for OpenWebUI.";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.openWebUiPort 8080 ];

    # 1. SWITCH BACKEND TO PODMAN
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers = {
      llama-cpp = {
        image = "rocm/llama.cpp:llama.cpp-b6652.amd0_rocm7.0.0_ubuntu24.04_server";
        autoStart = true;
        ports = [ "8080:8080" ];
        environment = {
          # Force ROCm to treat your Strix Halo (gfx1151) as a 7900 XTX (gfx1100)
          "HSA_OVERRIDE_GFX_VERSION" = "11.0.0";

          # Optional: Optimizations for APUs
          "HSA_ENABLE_SDMA" = "0"; # Often fixes "queue evicted" issues on APUs
        };
        volumes = [
        "${cfg.modelPath}:/models"
        ];

        extraOptions = [
          "--device=/dev/kfd"
          "--no-healthcheck"
          "--device=/dev/dri"
          # Podman doesn't always need group-add=video if the user is correct,
          # but we keep it for safety with ROCm.
          "--group-add=video"
          "--cap-add=SYS_RESOURCE"
        ];
        cmd = [
          "-m" "/models/${cfg.modelName}"
          "--host" "0.0.0.0"
          "--port" "8080"
          "-c" "${toString cfg.contextSize}"
          "-ngl" "99"
        ];
      };

      open-webui = {
        image = "ghcr.io/open-webui/open-webui:main";
        autoStart = true;
        ports = [ "${toString cfg.openWebUiPort}:8080" ];
        volumes = [ "open-webui-data:/app/backend/data" ];
        environment = {
          # Podman uses 'host.containers.internal', but we map 'host.docker.internal' below for compatibility
          OPENAI_API_BASE_URL = "http://host.docker.internal:8080/v1";
          OPENAI_API_KEY = "sk-no-key-required";
          WEBUI_NAME = "Talos AI";
        };
        # 2. PODMAN NETWORKING FIX
        # This maps the magic docker hostname to the host gateway in Podman
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
    };
  };
}
