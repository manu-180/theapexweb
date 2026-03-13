abstract final class AnalyticsEvents {
  // Landing
  static const landingViewed = 'landing_viewed';
  static const heroPrimaryCtaClicked = 'hero_primary_cta_clicked';

  // Services
  static const serviceTabViewed = 'service_tab_viewed';
  static const planCardCtaClicked = 'plan_card_cta_clicked';

  // Contact Modal
  static const contactModalOpened = 'contact_modal_opened';

  // Contact Form
  static const contactFormStarted = 'contact_form_started';
  static const contactFormSubmitted = 'contact_form_submitted';
  static const contactFormFailed = 'contact_form_failed';

  // Booking
  static const bookingSlotSelected = 'booking_slot_selected';
  static const bookingSubmitted = 'booking_submitted';
  static const bookingFailed = 'booking_failed';

  // WhatsApp
  static const whatsappClicked = 'whatsapp_clicked';

  // Payment
  static const paymentLinkGenerated = 'payment_link_generated';
  static const paymentLinkFailed = 'payment_link_failed';

  // Case Studies
  static const caseStudyOpened = 'case_study_opened';
  static const caseStudyCtaClicked = 'case_study_cta_clicked';
}
