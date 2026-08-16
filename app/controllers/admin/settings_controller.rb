class Admin::SettingsController < Admin::BaseController
  def show
    @setting_groups = AppSetting.definition_groups
    @setting_values = AppSetting.value_map
  end

  def update
    AppSetting.update_settings!(settings_params)
    redirect_to admin_settings_path, notice: "Settings updated."
  end

  private

  def settings_params
    params.fetch(:app_settings, {}).permit(AppSetting::DEFINITIONS.keys)
  end
end
