import { LightningElement,track,wire,api} from 'lwc';
import getPlantdetails from '@salesforce/apex/PicklistController.getPlantdetails';
let i=0;
export default class PicklistComponent extends LightningElement {
@track items =[];
@track value = '';
@track selectedOption= '';
@wire(getPlantdetails) 
plantdetails({data,error}){
    if(data){
        for(i=0; i<data.lenght; i++){
            console.log('id=' + data[i].Id);
            this.items =[...this.items,{value: data[i].Name, label: data[i].Name}];
        }
        this.error = undefined;
    }
    else if (error) {
        this.error = error;
       this.PlantAssets = undefined;
    }

}
get statusOptions() {
    console.log(this.items);
    return this.items;
}
handleChange(event) {
    // Get the string of the "value" attribute on the selected option
    const selectedOption = event.detail.value;
    console.log('selectedOption=' + selectedOption);
    alert('you have selected :' + this.selectedOption);
}
}