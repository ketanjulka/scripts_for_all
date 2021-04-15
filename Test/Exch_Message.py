from exchangelib import DELEGATE, IMPERSONATION, Account, Credentials, \
    EWSDateTime, EWSTimeZone, Configuration, NTLM, CalendarItem, Message, \
    Mailbox, Attendee, Q, ExtendedProperty, FileAttachment, ItemAttachment, \
    HTMLBody, Build, Version

credentials = Credentials(username='o365experts\\exch_svc', password='August@1983')

config = Configuration(server='mail.m365experts.info', credentials=credentials)

account = Account(primary_smtp_address='administrator@m365experts.info', config=config,
                  autodiscover=False, access_type=IMPERSONATION)

#for item in account.inbox.all().order_by('-datetime_received')[:100]:
#    print(item.subject, item.sender, item.datetime_received)

email = account.inbox.filter(subject = 'Test')






