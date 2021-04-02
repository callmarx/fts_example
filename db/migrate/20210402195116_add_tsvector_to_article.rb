class AddTsvectorToArticle < ActiveRecord::Migration[6.1]
  def up
    add_column :articles, :tsv, :tsvector
    add_index :articles, :tsv, using: :gin

    # create a text search configuration with a pt-br dictionary
    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION custom_pt_br (COPY = pg_catalog.portuguese);
      ALTER TEXT SEARCH CONFIGURATION custom_pt_br
      ALTER MAPPING
      FOR hword, hword_part, word with unaccent, portuguese_stem;

      CREATE TEXT SEARCH DICTIONARY public.portuguese_dict (
        TEMPLATE = ispell,
        DictFile = pt_br,
        AffFile = pt_br,
        stopwords = portuguese
      );

      ALTER TEXT SEARCH CONFIGURATION custom_pt_br
      ALTER MAPPING FOR hword, hword_part, word
      WITH public.portuguese_dict, simple;
    SQL

    # create updated trigger using the new text search configuration for tsv and update existing tsv
    execute <<-SQL
      CREATE TRIGGER articles_tsvector_update BEFORE INSERT OR UPDATE
      ON articles FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'public.custom_pt_br', title, content
      );

      UPDATE articles SET tsv = (to_tsvector('public.custom_pt_br', title || content));
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER articles_tsvector_update
      ON articles;

      DROP TEXT SEARCH CONFIGURATION custom_pt_br;

      DROP TEXT SEARCH DICTIONARY public.portuguese_dict;
    SQL

    remove_index :articles, :tsv
    remove_column :articles, :tsv
  end
end
