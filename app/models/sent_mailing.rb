# encoding: UTF-8

class SentMailing < ActiveRecord::Base

  PDF_DIR = "sent_mailing_pdfs"

  belongs_to :mailing
  has_many :recipients

  validates_presence_of :mailing_id

  after_save :generate_pdf

  # This generates a pdf version of the newsletter.
  # This has no layout and is just for proofing what content was sent to the recipients.
  def generate_pdf
    Dir.mkdir(PDF_DIR) unless File.exists?(PDF_DIR)
    Prawn::Document.generate(self.pdf_path, :page_size => "A4", :orientation => :portrait) do |pdf|
      pdf.text("Name: #{self.mailing.name}")
      pdf.text("Betreff: #{self.mailing.subject}")
      pdf.text("Versand-Datum: #{self.created_at.strftime("%d.%m.%Y um %H:%M Uhr")}\n\n")
      pdf.text("Inhalt:\n\n")
      self.mailing.page.elements.each do |c|
        c.contents.select{|a| ["EssenceText", "EssenceRichtext"].include?(a.essence_type)}.each do |text_content|
          if c.contents.first == text_content
            pdf.text("<b>#{text_content.essence_type == 'EssenceText' ? text_content.essence.body : text_content.essence.stripped_body}</b>")
          else
            pdf.text(text_content.essence_type == "EssenceText" ? text_content.essence.body : text_content.essence.stripped_body)
          end
        end
        c.all_contents_by_type("EssencePicture").each do |i|
          pdf.image(i.essence.picture.file_path) rescue nil
        end
        pdf.text("\n")
      end
      pdf.text("\nEmpfängerliste:\n\n")
      self.recipients(true).each do |r|
        pdf.text(r.email)
      end
    end
  end

  def pdf_path#:nodoc:
    "#{PDF_DIR}/#{self.id}.pdf"
  end

end
