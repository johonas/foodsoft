class Admin::UsersController < Admin::BaseController
  inherit_resources

  def index
    @q = User.natural_order.ransack(params[:q])
    @users = @q.result.page(params[:page]).per(@per_page)

    # if somebody uses the search field:
    @users = @users.natural_search(params[:user_name]) unless params[:user_name].blank?
  end

  def sudo
    @user = User.find(params[:id])
    login @user
    redirect_to root_path, notice: I18n.t('admin.users.controller.sudo_done', user: @user.name)
  end
end
