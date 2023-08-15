class GptMigrate::Globals < Struct::new(
  :source_dir, :target_dir, :source_lang, :target_lang,
  :source_entry, :source_directory_structure, :operating_system,
  :testfiles, :sourceport, :targetport, :guidelines, :ai, keyword_init: true
)
end