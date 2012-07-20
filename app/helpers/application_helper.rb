module ApplicationHelper

  def code(text, language)
    #text.gsub(/\<code( lang="lang")?\>(.+?)\<\/code\>/m) do
      CodeRay.scan(text, language).div(:line_numbers => :table)
    #end
  end

  def codelines(text)
    CodeRay.scan(text, :c).loc
  end

end
