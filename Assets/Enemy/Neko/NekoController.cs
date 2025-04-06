using UnityEngine;

using UnityEngine.AI;

public class NekoCon : MonoBehaviour
{
    public Transform[] targetPoint;
    public int currentPoint;

    public NavMeshAgent agent;
    public Animator animator;

    public float waitAtPoint = 2f;
    private float waitCounter;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        waitCounter = waitAtPoint;
    }

    // Update is called once per frame
    void Update()
    {
        agent.SetDestination(targetPoint[currentPoint].position);

        if (agent.remainingDistance <= .2f)
        {
            if(waitCounter > 0)
            {
                waitCounter -= Time.deltaTime;
                animator.SetBool("Walk", false);
            }
            else
            {
                currentPoint++;
                waitCounter = waitAtPoint;
                animator.SetBool("Walk", true);
            }

            if(currentPoint >= targetPoint.Length)
            {
                currentPoint = 0;
            }
            agent.SetDestination(targetPoint[currentPoint].position);
        }
    }
}
