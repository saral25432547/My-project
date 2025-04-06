using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(InputManager))]
[RequireComponent(typeof(CharacterController))]
public class controller : MonoBehaviour
{
    [HideInInspector] public InputManager inputManager;
    [HideInInspector] public CharacterController characterController;
    [HideInInspector] public Animator animator;

    public float gravityPower = -9.8f;
    public float jumpValue = -9.8f;

    [Range(1, 4)] public float movementSpeed = 2;
    [Range(0, 0.5f)] public float groundClearance;
    [Range(0, 1f)] public float groundDistance;

    [HideInInspector] public Vector3 motionVector, gravityVector;

    private float gravityForce = -9.18f;

    void Start()
    {
        inputManager = GetComponent<InputManager>();
        characterController = GetComponent<CharacterController>();
        animator = GetComponent<Animator>();
    }

    void Update()
    {
        movement();
    }

    void movement()
    {
        animator.SetFloat("vertical", inputManager.vertical);
        animator.SetFloat("horizontal", inputManager.horizontal);
        animator.SetBool("grounded", isGrounded());
        animator.SetFloat("jump", inputManager.jump);

        if (isGrounded() && gravityVector.y < 0)
            gravityVector.y = -2;

        gravityVector.y += gravityPower * Time.deltaTime;
        characterController.Move(gravityVector * Time.deltaTime);

        if (isGrounded())
        {
            motionVector = transform.right * inputManager.horizontal + transform.forward * inputManager.vertical;
            characterController.Move(motionVector * movementSpeed * Time.deltaTime);
        }

        if (inputManager.jump != 0)
        {
            jump();
        }
    }

    void jump()
    {
        if (isGrounded())
            characterController.Move(transform.up * (jumpValue * -2 * gravityForce) * Time.deltaTime);
    }

    bool isGrounded()
    {
        return Physics.CheckSphere(new Vector3(transform.position.x, transform.position.y - groundDistance, transform.position.z), groundClearance);
    }

    void OnGUI()
    {
        float rectPos = 50;
        GUI.Label(new Rect(20, rectPos, 200, 20), "is Grounded: " + isGrounded());
        rectPos += 30f;
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.DrawSphere(new Vector3(transform.position.x, transform.position.y - groundDistance, transform.position.z), groundClearance);
    }
}