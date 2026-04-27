class MakeAppointmentsScheduledAtNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :appointments, :scheduled_at, true
  end
end
