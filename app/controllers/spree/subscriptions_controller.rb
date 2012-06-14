class Spree::SubscriptionsController < Spree::BaseController

  def gibbon
    gibbon  ||= Gibbon.new(Spree::Config.get(:mailchimp_api_key))
  end

  def create
    @errors = []

    if params[:email].blank?
      @errors << t('missing_email')
    elsif params[:email] !~ /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
      @errors << t('invalid_email_address')
    else
      begin
        @mc_member = gibbon.listMemberInfo(:id => Spree::Config.get(:mailchimp_list_id), :email_address => params[:email])
      end

      if @mc_member["success"] == 1
        @errors << t('that_address_is_already_subscribed')

      elsif @mc_member["errors"] == 1
        begin
          gibbon.listSubscribe({:id => Spree::Config.get(:mailchimp_list_id), :email_address => params[:email], :email_type => "html", :double_optin => Spree::Config.get(:mailchimp_double_opt_in)})
       end
      end
    end

    respond_to do |wants|
      wants.js
    end

  end
end
