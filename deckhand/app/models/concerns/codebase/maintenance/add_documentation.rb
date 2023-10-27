class Codebase::Maintenance::AddDocumentation < ApplicationAgent
  arguments :files

  delegate :codebase, to: :context

  def run
    branch_name = "add-documentation-#{SecureRandom.hex(8)}"
    ran = false
    codebase.new_branch(branch_name) do |status|
      puts "Already ran!? #{status.inspect}" if ran
      if status == 0 && !ran
        ran = true
        puts "Going to add documentation to #{files.inspect}: #{status.inspect}"
        files.each do |file|
          next unless add_documentation_to_file(file)

          codebase.commit("Add automatically generated documentation to #{file}")
        end

        codebase.git_push(branch_name) do |status|
          raise "Failed to push changes to #{codebase.name}: #{status.inspect}" unless status == 0

          codebase.merge_request(title: 'Add documentation',
                                 body: 'This merge request was automatically generated by Bosun Deckhand.', branch_name:)
        end
      end
    end
  end

  def add_documentation_to_file(file)
    file_content = File.read(File.join(codebase.path, file))

    prediction = run(WriteDocumentationAgent, file_content, context:)

    return if prediction.blank?

    File.write(File.join(codebase.path, file), prediction)
  end
end
