class Spree::SubscriptionsController < Spree::BaseController

  def gibbon
    @gibbon  ||= Gibbon.new(Spree::Config.get(:mailchimp_api_key))
  end

  def create
    @errors = []

    if params[:email].blank?
      @errors << t('missing_email')
    elsif params[:email] !~ /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
      @errors << t('invalid_email_address')
    else
      begin
        self.class.benchmark "Checking if address exists and/or is valid" do
          @mc_member = gibbon.listMemberInfo(Spree::Config.get(:mailchimp_list_id), params[:email])
        end
        rescue Gibbon::ListError => e
      end

      if @mc_member
        @errors << t('that_address_is_already_subscribed')
      else
        begin
          self.class.benchmark "Adding mailchimp subscriber" do
            gibbon.list_subscribe(Spree::Config.get(:mailchimp_list_id), params[:email], {}, MailChimpSync::Sync::mc_subscription_opts)
          end
        #rescue Hominid::ValidationError => e
          #@errors << t('invalid_email_address')
       # end
      end
    end

    respond_to do |wants|
      wants.js
    end
  end
end
