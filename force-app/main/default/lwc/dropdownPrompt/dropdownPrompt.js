import { LightningElement,api } from 'lwc';

export default class DropdownPrompt extends LightningElement {
@api record;  

handleSelect(event){
    const selectEvent = new CustomEvent('dropdownvalueselect', {  
        detail: this.record,  
        bubbles: true,  
        composed: true  
        });  
        this.dispatchEvent(selectEvent);
}

}