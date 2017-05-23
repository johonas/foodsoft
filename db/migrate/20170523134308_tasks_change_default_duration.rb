class TasksChangeDefaultDuration < ActiveRecord::Migration
  def change
    change_column_default(:tasks, :duration, nil)
  end
end
