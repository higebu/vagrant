require "google/protobuf/well_known_types"

module VagrantPlugins
  module CommandServe
    module Service
      class GuestService < Hashicorp::Vagrant::Sdk::GuestService::Service
        prepend Util::HasBroker
        prepend Util::ExceptionLogger
        LOGGER  = Log4r::Logger.new("vagrant::command::serve::command")

        def detect_spec(*_)
          SDK::FuncSpec.new(
            name: "detect_spec",
            args: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Args.Target",
                name: "",
              )
            ],
            result: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Platform.DetectResp",
                name: "",
              ),
            ],
          )
        end

        def detect(req, ctx)
          ServiceInfo.with_info(ctx) do |info|
            plugin_name = info.plugin_name
            raw_target = req.args.detect { |a|
              a.type == "hashicorp.vagrant.sdk.Args.Target"
            }&.value&.value
            target = Client::Target.load(raw_target, broker: broker)
            machine_client = target.to_machine
            # TODO: this machine should be a Remote::Machine
            machine = machine_client

            plugin = Vagrant.plugin("2").manager.guests[plugin_name.to_s.to_sym].to_a.first
            if !plugin
              LOGGER.debug("Failed to locate guest plugin for: #{plugin_name}")
              raise "Failed to locate guest plugin for: #{plugin_name.inspect}"
            end
            guest = plugin.new
            begin
              detected = guest.detect?(machine)
            rescue => err
              LOGGER.debug("error detecting guest plugin!")
              LOGGER.error(err)
              LOGGER.debug("#{err.class}: #{err}\n#{err.backtrace.join("\n")}")
              detected = false
            end

            LOGGER.debug("detected? #{detected}")
            SDK::Platform::DetectResp.new(
              detected: detected,
            )
          end
        end

        def parents_spec(*_)
          SDK::FuncSpec.new(
            name: "parents_spec",
            result: [
              type: "hashicorp.vagrant.sdk.Platform.ParentsResp",
              name: "",
            ]
          )
        end

        def parents(req, ctx)
          ServiceInfo.with_info(ctx) do |info|
            plugin_name = info.plugin_name
            plugin = Vagrant.plugin("2").manager.guest[plugin_name.to_s.to_sym].to_a.first
            if !plugin
              raise "Failed to locate guest plugin for: #{plugin_name.inspect}"
            end
            SDK::Platform::ParentsResp.new(
              parents: plugin.new.parents
            )
          end
        end

        def has_capability_spec(*_)
          SDK::FuncSpec.new(
            name: "has_capability_spec",
            args: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Args.NamedCapability",
                name: "",
              )
            ],
            result: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Platform.Capability.CheckResp",
                name: "",
              ),
            ],
          )
        end

        def has_capability(req, ctx)
          # TODO
        end

        # TODO: Need to be able to specify all the arguments that are required
        #       for the capability
        def capability_spec(*_)
          SDK::FuncSpec.new(
            name: "has_capability_spec",
            args: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Args.NamedCapability",
                name: "",
              ),
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Args.Target",
                name: "",
              ),
            ],
            result: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Platform.Capability.CheckResp",
                name: "",
              ),
            ],
          )
        end

        # TODO: Need to be able to specify all the arguments that are required
        #       for the capability
        def capability(req, ctx)
          # TODO
        end
      end
    end
  end
end
