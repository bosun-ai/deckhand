class GptMigrate::Globals < Struct::new(
  :source_dir, :target_dir, :source_lang, :target_lang,
  :entry_point, :source_directory_structure, :operating_system,
  :testfiles, :source_port, :target_port, :guidelines, :ai,
  keyword_init: true
)
end