import { LightningElement,track } from 'lwc';

export default class G1G2Prompt extends LightningElement {
    @track SelectedPlantRecord; 
    handledropdownselectedpalnt(event){
        this.SelectedPlantRecord = event.detail; 
    }
}