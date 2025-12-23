{
  lib,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.immich;
  rdomain = config.networking.domain;

  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;
in
{
  options.garden.services.immich = mkServiceOption "immich" {
    port = 3007;
    host = "0.0.0.0";
    domain = "photos.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      postgresql.enable = true;

      borgbackup.jobs.immich = {
        paths = [ config.services.immich.mediaLocation ];
        exclude = [ "**/thumbs/**" ];
        repo = "immich";
        passkeyFile = config.sops.secrets.borg-immich-pass.path;
      };
    };

    sops.secrets = {
      immich-clientid = mkSecret {
        file = "immich";
        key = "clientid";
      };
      borg-immich-pass = mkSecret {
        file = "borg";
        key = "immich-passphrase";
      };
    };

    users.users.immich.extraGroups = [
      "video"
      "render"
    ];

    services = {
      immich = {
        enable = true;
        inherit (cfg) port host;
        openFirewall = true;

        # give it acess to all hardware devices
        accelerationDevices = null;

        # where to store our media
        mediaLocation = "/srv/storage/immich";

        settings = {
          backup = {
            database = {
              enabled = false; # we use borg for this
              cronExpression = "0 02 * * *";
              keepLastAmount = 14;
            };
          };
          ffmpeg = {
            accel = "disabled";
            accelDecode = false;
            acceptedAudioCodecs = [
              "aac"
              "mp3"
              "libopus"
            ];
            acceptedContainers = [
              "mov"
              "ogg"
              "webm"
            ];
            acceptedVideoCodecs = [
              "h264"
            ];
            bframes = -1;
            cqMode = "auto";
            crf = 23;
            gopSize = 0;
            maxBitrate = "0";
            preferredHwDevice = "auto";
            preset = "ultrafast";
            refs = 0;
            targetAudioCodec = "aac";
            targetResolution = "720";
            targetVideoCodec = "h264";
            temporalAQ = false;
            threads = 0;
            tonemap = "hable";
            transcode = "required";
            twoPass = false;
          };
          image = {
            colorspace = "p3";
            extractEmbedded = false;
            fullsize = {
              enabled = false;
              format = "jpeg";
              quality = 80;
            };
            preview = {
              format = "jpeg";
              quality = 80;
              size = 1440;
            };
            thumbnail = {
              format = "webp";
              quality = 80;
              size = 250;
            };
          };

          job = {
            backgroundTask.concurrency = 5;
            faceDetection.concurrency = 2;
            library.concurrency = 5;
            metadataExtraction.concurrency = 5;
            migration.concurrency = 5;
            notifications.concurrency = 5;
            ocr.concurrency = 1;
            search.concurrency = 5;
            sidecar.concurrency = 5;
            smartSearch.concurrency = 2;
            thumbnailGeneration.concurrency = 3;
            videoConversion.concurrency = 1;
          };

          library = {
            scan = {
              cronExpression = "0 0 * * *";
              enabled = true;
            };
            watch.enabled = false;
          };

          logging = {
            enabled = true;
            level = "log";
          };

          machineLearning = {
            enabled = true;

            availabilityChecks = {
              enabled = true;
              interval = 30000;
              timeout = 2000;
            };

            clip = {
              enabled = true;
              modelName = "ViT-B-32__openai";
            };

            duplicateDetection = {
              enabled = true;
              maxDistance = 0.01;
            };

            facialRecognition = {
              enabled = true;
              maxDistance = 0.5;
              minFaces = 3;
              minScore = 0.65;
              modelName = "buffalo_l";
            };

            ocr = {
              enabled = true;
              maxResolution = 736;
              minDetectionScore = 0.5;
              minRecognitionScore = 0.8;
              modelName = "PP-OCRv5_mobile";
            };

            urls = [ "http://127.0.0.1:3003" ];
          };

          map = {
            enabled = true;
            darkStyle = "https://tiles.immich.cloud/v1/style/dark.json";
            lightStyle = "https://tiles.immich.cloud/v1/style/light.json";
          };

          metadata.faces.import = false;
          newVersionCheck.enabled = false;

          nightlyTasks = {
            clusterNewFaces = true;
            databaseCleanup = true;
            generateMemories = true;
            missingThumbnails = true;
            startTime = "00:00";
            syncQuotaUsage = true;
          };

          notifications.smtp = {
            enabled = false;
            from = "";
            replyTo = "";
            transport = {
              host = "";
              ignoreCert = false;
              password = "";
              port = 587;
              secure = false;
              username = "";
            };
          };

          oauth = {
            enabled = true;
            autoLaunch = false;
            autoRegister = true;
            buttonText = "Login with kanidm";
            clientId = "immich";
            clientSecret._secret = config.sops.secrets.immich-clientid.path;
            defaultStorageQuota = null;
            issuerUrl = "https://${config.garden.services.kanidm.domain}/oauth2/openid/immich";
            mobileOverrideEnabled = true;
            mobileRedirectUri = "https://${cfg.domain}/api/oauth/mobile-redirect";
            profileSigningAlgorithm = "none";
            roleClaim = "immich.access";
            scope = "openid email profile";
            signingAlgorithm = "ES256";
            storageLabelClaim = "preferred_username";
            storageQuotaClaim = "immich_quota";
            timeout = 30000;
            tokenEndpointAuthMethod = "client_secret_post";
          };

          passwordLogin.enabled = false;
          reverseGeocoding.enabled = true;

          server = {
            externalDomain = "https://${cfg.domain}";
            loginPageMessage = "";
            publicUsers = false;
          };

          storageTemplate = {
            enabled = true;
            hashVerificationEnabled = true;
            template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
          };

          templates.email = {
            albumInviteTemplate = "";
            albumUpdateTemplate = "";
            welcomeTemplate = "";
          };

          theme.customCss = "";

          trash = {
            days = 30;
            enabled = true;
          };

          user.deleteDelay = 7;
        };
      };

      cloudflared.tunnels.${config.networking.hostName} = {
        ingress.${cfg.domain} = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
