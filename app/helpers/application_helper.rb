module ApplicationHelper

  def code(text, language)
    #text.gsub(/\<code( lang="lang")?\>(.+?)\<\/code\>/m) do
      CodeRay.scan(text, language).div(:line_numbers => :table)
    #end
  end

  def codelines(text)
    CodeRay.scan(text, :c).loc
  end

  private

  def require_login!
    unless user_signed_in?
      redirect_to login_path,
                  alert: "Bitte melden Sie sich zuerst an."
    end
  end

end
