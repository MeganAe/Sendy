// Sendy: keep failure/cancellation distinct from a successful transfer.
import 'package:localsend_isolates/model/session_status.dart';

enum SendyTransferPhase { waiting, active, success, problem }

SendyTransferPhase sendyTransferPhase(SessionStatus status) => switch (status) {
  SessionStatus.waiting => SendyTransferPhase.waiting,
  SessionStatus.sending => SendyTransferPhase.active,
  SessionStatus.finished => SendyTransferPhase.success,
  SessionStatus.recipientBusy ||
  SessionStatus.declined ||
  SessionStatus.tooManyAttempts ||
  SessionStatus.finishedWithErrors ||
  SessionStatus.canceledBySender ||
  SessionStatus.canceledByReceiver => SendyTransferPhase.problem,
};
