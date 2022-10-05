namespace :storage do
  # https://stackoverflow.com/a/69827183/3877528
  desc "Ensures all files are mirrored"
  task mirror_all: [:environment] do
    ActiveStorage::Blob.all.each do |blob|
      ActiveStorage::Blob.service.try(:mirror, blob.key, checksum: blob.checksum)
    rescue ActiveStorage::FileNotFoundError
      # Add some message or warning here if you fancy
      puts "Missing file for blob #{ blob.key }!"
    end

    Rails.logger.info "Mirroring done!"
  end

  desc "Change each blob service name to DO"
  task switch: [:environment] do
    service_name = :digitalocean

    ActiveStorage::Blob.update_all(service_name:)

    Rails.logger.info "All blobs will now be served from #{ service_name }!"
  end

  task cleanup: :environment do
    ActiveStorage::Blob.unattached.each(&:purge)
  end

  # https://stackoverflow.com/a/70247764/3877528
  # Usage:
  #   - rake "remove_orphan_files"
  #   - rake "remove_orphan_files[false]"
  desc "Remove files not associated with any blob"
  task :remove_orphan_files, [:dry_run] => :environment do |_t, args|
    include ActionView::Helpers::NumberHelper
    dry_run = true unless args.dry_run == "false"

    puts("[#{Time.now}] Running remove_orphan_files :: INI#{" (dry_run activated)" if dry_run}")

    files = Dir["storage/??/??/*"]
    orphan_files = files.select do |file|
      !ActiveStorage::Blob.exists?(key: File.basename(file))
    end

    sum = 0
    orphan_files.each do |file|
      puts("Deleting File: #{file}#{" (dry_run activated)" if dry_run}")
      sum += File.size(file)
      FileUtils.remove(file) unless dry_run
    end

    puts "Size Liberated: #{number_to_human_size(sum)}#{" (dry_run activated)" if dry_run}"

    puts("[#{Time.now}] Running remove_orphan_files :: END#{" (dry_run activated)" if dry_run}")
  end
end
