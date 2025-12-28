{ config, lib, pkgs, ... }:

let
  cfg = config.modules.containers.ai;
in
{
  options.modules.containers.ai = {
    enable = lib.mkEnableOption "AI Stack (Strix Halo Custom)";
    modelPath = lib.mkOption { type = lib.types.path; default = "/home/joe/models"; };
    modelName = lib.mkOption { type = lib.types.str; default = ""; };
  };

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers = {

      llama-cpp = {
        # THE FIX: Specialized Strix Halo container
        image = "kyuz0/amd-strix-halo-toolboxes:rocm-6.4.4";

        autoStart = true;
        ports = [ "8080:8080" ];

        environment = {
          # NO SPOOFING: Let the custom image see "gfx1151" natively.

          # APU Hardware Constraints (Still required for stability)
          "HSA_ENABLE_SDMA" = "0";      # Prevents hangs
          "GGML_CUDA_NO_PINNED" = "1";  # Prevents RAM trashing
        };

        # We assume 'llama-server' is in the PATH of this toolbox image.
        entrypoint = "llama-server";

        cmd = [
          "-m" "/models/qwen2.5-coder-32b-instruct-q8_0.gguf"
          "--host" "0.0.0.0"
          "--port" "8080"

          "-c" "16384"
          "-ngl" "99"
          "--no-mmap"   # Keep this for smoothness
          # "-fa"       # Flash Attention might not be compiled in; enable manually if it works
        ];

        extraOptions = [
          "--device=/dev/kfd"
          "--device=/dev/dri"
          "--security-opt=label=disable"
          "--no-healthcheck"
        ];

        volumes = [
          "${cfg.modelPath}:/models"
          "/home/joe/containers/rocm:/root/.cache"
        ];
      };

      open-webui = {
        image = "ghcr.io/open-webui/open-webui:main";
        autoStart = true;
        environment = {
          "PORT" = "3000";
          "OLLAMA_BASE_URL" = "http://127.0.0.1:8080";
          "WEBUI_AUTH" = "false";
        };
        volumes = [ "open-webui-data:/app/backend/data" ];
        extraOptions = [ "--network=host" ];
      };
    };
  };
}
