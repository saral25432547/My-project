using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Pool;

public class Enemy : MonoBehaviour
{
    private NavMeshAgent agent;
    private Transform player;
    [SerializeField] public float damage = 10f; // ✅ ทำเป็น public หรือใช้ property get
    public Animator animator;  // เชื่อมต่อกับ Animator
    public Transform TargetPoint;

    private IObjectPool<Enemy> enemyPool;
    private DropSystem dropSystem;
    
    public float maxhealth = 50f;
    public float health = 50f; // เพิ่มตัวแปรเลือดของศัตรู
    public EnemyHealthBar healthbar;

    public GameObject[] Effects; // ตัวแปรอาเรย์ของเอฟเฟกต์
    public Transform effectSpawnPoint; // จุดที่ใช้ในการปล่อยเอฟเฟกต์ (เช่น จุดกลางของศัตรู)

    public event System.Action OnDeath;  // ✅ เพิ่ม event ที่จะถูกเรียกเมื่อศัตรูตาย
    
    public void SetPool(IObjectPool<Enemy> pool)
    {
        enemyPool = pool;
    }

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        // ใช้ PlayerController แทน Player
        player = FindObjectOfType<PlayerController>().transform;
        health = maxhealth;
        healthbar.SetMaxHealth(maxhealth);
        dropSystem = GetComponent<DropSystem>(); // ✅ ดึงระบบดรอปจาก Object เดียวกัน
    }
    
    public enum AIState
    {
        isDead, isSeekTargetPoint, isSeekPlayer, isAttack
    }
    public AIState state;

    public void TakeDamage(float damage)
    {
        health -= damage; // ลดเลือดจากดาเมจที่ได้รับ
        Debug.Log(gameObject.name + " ได้รับดาเมจ: " + damage + " เหลือ HP: " + health);

        healthbar.SetHealth(health);
        if (health <= 0f)
        {
            Die(); // เรียกฟังก์ชันตายเมื่อเลือดหมด
        }
    }

    // ฟังก์ชันทำให้ศัตรูตาย
    void Die()
    {
        // เรียก event เมื่อศัตรูตาย
        OnDeath?.Invoke(); // เรียก event

        foreach (GameObject effect in Effects)
        {
            GameObject spawnedEffect = Instantiate(effect, effectSpawnPoint.position, Quaternion.identity);

            // ลบเอฟเฟกต์หลังเล่นจบ
            ParticleSystem ps = spawnedEffect.GetComponent<ParticleSystem>();
            if (ps != null)
            {
                Destroy(spawnedEffect, ps.main.duration + ps.main.startLifetime.constantMax);
            }
            else
            {
                Destroy(spawnedEffect, 2f); // กำหนดดีเลย์ลบ ถ้าไม่มี ParticleSystem
            }
        }

        Debug.Log(gameObject.name + " ตายแล้ว!");
        if (dropSystem != null)
        {
            dropSystem.DropLoot(transform.position); // ดรอปของ
        }
        Destroy(gameObject); // ทำลายศัตรู
    }

    private bool isAttacking = false; // ✅ ตัวแปรล็อกการโจมตี

    void Update()
    {
        float distanceToPlayer = Vector3.Distance(transform.position, PlayerController.instance.transform.position);
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);

        // ✅ ตรวจสอบว่ากำลังเล่นอนิเมชั่นโจมตีอยู่หรือไม่
        if (stateInfo.IsName("Attack"))
        {
            isAttacking = true; // ล็อกการโจมตี
            if (stateInfo.normalizedTime >= 1.0f) // ✅ ถ้าอนิเมชั่นเล่นจบ (normalizedTime >= 1.0)
            {
                isAttacking = false; // ปลดล็อก
            }
        }

        // ✅ ถ้ากำลังโจมตี ห้ามเปลี่ยน AI State
        if (!isAttacking)
        {
            if (distanceToPlayer >= 1.3f && distanceToPlayer <= 20f)
            {
                state = AIState.isSeekPlayer;
            }
            else if (distanceToPlayer > 8)
            {
                state = AIState.isSeekTargetPoint;
            }
            else
            {
                state = AIState.isAttack;
            }
        }

        switch (state)
        {
            case AIState.isDead:
                break;

            case AIState.isSeekPlayer:
                if (!isAttacking) // ✅ ถ้าไม่ได้โจมตีเท่านั้นถึงให้เคลื่อนที่
                {
                    agent.isStopped = false;
                    agent.SetDestination(PlayerController.instance.transform.position);
                    animator.SetBool("Attack", false);
                }
                break;

            case AIState.isSeekTargetPoint:
                if (!isAttacking) // ✅ ถ้าไม่ได้โจมตีเท่านั้นถึงให้เคลื่อนที่
                {
                    agent.isStopped = false;
                    agent.stoppingDistance = 0f;
                    agent.SetDestination(TargetPoint.position);
                }
                break;

            case AIState.isAttack:
                if (!isAttacking) // ✅ เริ่มการโจมตีเฉพาะเมื่อยังไม่อยู่ในโหมดโจมตี
                {
                    isAttacking = true;
                    agent.isStopped = true; // ✅ หยุดการเคลื่อนที่ขณะโจมตี
                    agent.velocity = Vector3.zero; // ✅ ทำให้ศัตรูหยุดสนิท
                    animator.SetBool("Attack", true);
                    animator.SetBool("Walk", false);
                    Debug.Log("Enemy is attacking: " + agent.isStopped);
                }
                break;
        }

        // ✅ ปรับให้ศัตรูเดินเฉพาะเมื่อไม่ได้โจมตี
        if (!agent.isStopped && agent.velocity.magnitude > 0.1f)
        {
            animator.SetBool("Walk", true);
        }
        else
        {
            animator.SetBool("Walk", false);
        }
    }

}