# frozen_string_literal: true

class ImportJob
  include Sidekiq::Job

  sidekiq_options queue: :imports, retry: 5

  def perform(import_id)
    import = Import.find_by(id: import_id)
    return if import.blank?

    users = {}

    import.file.open do |file|
      file.each_line do |line|
        external_id = line[0...10].to_i
        name = line[10...55].strip
        users[external_id] = { external_id:, name: }
      end
    end

    User.upsert_all(users.values, unique_by: :external_id)
  end
end
