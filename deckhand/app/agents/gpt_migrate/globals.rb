class GptMigrate::Globals < T::Struct

  prop :source_dir, String
  prop :target_dir, String
  prop :source_lang, String
  prop :target_lang, String
  prop :entry_point, String
  prop :source_directory_structure, T::Array[String]
  prop :operating_system, String
  prop :testfiles, T::Array[String]
  prop :source_port, Integer
  prop :target_port, Integer
  prop :guidelines, String
  prop :ai, String
end