using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputManager : MonoBehaviour{

    internal enum InputType{keyboard , mobile}
    [SerializeField]private InputType input;

    public float vertical ;
    public float horizontal; 
    public float jump; 
    public float fire;// Light attack
    public float fire1; // heavy attack
    public float shift;
    [HideInInspector]public float rawVertical , rawHorizontal;

    private float calculatedVertical;

    void Update(){
        
        if(input == InputType.mobile){

        }else{
            keyboardInput();
        }

    }

    void keyboardInput(){
        calculatedVertical = Input.GetAxis("Horizontal") != 0 && Input.GetAxis("Vertical") == 0 ? horizontal : Input.GetAxis("Vertical") >= 0 ?  Input.GetAxis("Vertical") :0 ;
        vertical = Mathf.Abs(calculatedVertical) * ( 1 + shift);

        horizontal = Mathf.Lerp(horizontal ,Input.GetAxis("Vertical") == 0 ? Input.GetAxis("Horizontal") : Input.GetAxis("Horizontal") /2  , 15 * Time.deltaTime) ;
        fire = Input.GetAxis("Fire1"); 
        fire1 = Input.GetAxis("Fire2"); 
        jump = Input.GetAxis("Jump");
        rawVertical = Input.GetAxis("Vertical");
        rawHorizontal = Input.GetAxis("Horizontal");
        shift = Mathf.Lerp(shift , Input.GetAxis("Fire3") , 5 * Time.deltaTime);

    }

}
