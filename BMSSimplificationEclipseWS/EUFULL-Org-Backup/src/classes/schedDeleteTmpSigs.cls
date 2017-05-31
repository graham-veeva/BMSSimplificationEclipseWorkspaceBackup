global class schedDeleteTmpSigs implements Schedulable{ 
  global void execute(SchedulableContext SC) {
        delete ([select Id from Document where Folder.Name = 'TempSigs' and CreatedDate < today]) ;
  }
}