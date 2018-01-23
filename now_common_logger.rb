require 'rack/common_logger'

module Rack
  class CommonLogger
    class_eval do
      private

      def mask_path_info(pi)
        '**REQUEST_PATH**'
      end

      def log(env, status, header, began_at)
        now = Time.now
        length = extract_content_length(header)

        msg = FORMAT % [
          env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
          env["REMOTE_USER"] || "-",
          now.strftime("%d/%b/%Y:%H:%M:%S %z"),
          env[REQUEST_METHOD],
          mask_path_info(env[PATH_INFO]),
          env[QUERY_STRING].empty? ? "" : "?#{env[QUERY_STRING]}",
          env[HTTP_VERSION],
          status.to_s[0..3],
          length,
          now - began_at ]

        logger = @logger || env[RACK_ERRORS]
        # Standard library logger doesn't support write but it supports << which actually
        # calls to write on the log device without formatting
        if logger.respond_to?(:write)
          logger.write(msg)
        else
          logger << msg
        end
      end
    end
  end
end
