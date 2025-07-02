class InvoiceEndPoints {
  static String getFinishedAppointments() => "/patient/my-finished-appointments";

  static String getDetailsInvoice({required String appointmentId, required String invoiceId}) =>
      "/patient/my-finished-appointments/$appointmentId/invoices/$invoiceId";
}
