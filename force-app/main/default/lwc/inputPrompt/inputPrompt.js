import { LightningElement, track, wire} from 'lwc';
import getPlantInfo from '@salesforce/apex/PromptController.getPlantInfo';
export default class InputPrompt extends LightningElement {
@track records;
@track showoptions = true;  
@track searchString = '';  
@track selectedName;  
@track noRecordsFlag = false; 
  
@wire(getPlantInfo,{Searchkey:'$searchString'} )
WiredPlant({error,data}){
if(data){
this.records = data; 
this.error = undefined; 
this.noRecordsFlag = this.records.length === 0 ? true : false;  
}else if(error){
    this.error = error;
    this.data = undefined;
}
}
handleKeyChange(event) {  
this.showoptions = true;  
this.searchString = event.target.value;  
}  
handledropdownvalueselect(event){
    this.selectedName = event.detail.Plant_Name__c;  
    this.showoptions = false;  
}
}