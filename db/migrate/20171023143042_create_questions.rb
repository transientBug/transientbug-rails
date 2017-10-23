class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :questionnaire, foreign_key: true

      t.text :title
      t.text :question

      t.integer :type

      t.timestamps
    end
  end
end
