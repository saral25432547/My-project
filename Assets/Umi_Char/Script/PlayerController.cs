using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour
{
    //playerMove
    public CharacterController controller;
    public bool RulerBlade = false;  // ใช้สำหรับติดตามสถานะการถืออาวุธ
    public bool isGreatSwordMode = false; // 🔹 ติดตามโหมดอาวุธ (ดาบยาว / ดาบใหญ่)

    private Animator animator;
    [SerializeField] private GameObject weapon;
    [SerializeField] private Animator RulerBladeController;
    public bool canMove = true;  // ✅ ควบคุมการเคลื่อนที่ระหว่างโจมตี
    public float movementSpeedMultiplier = 1f;  // ✅ ตัวคูณความเร็ว
    
    public GameObject[] sparkEffects; // 🔥 เก็บ 2 เอฟเฟคที่จะใช้

    public float maxHealth = 100f;
    public float health = 100f;  // ตัวแปรสำหรับเก็บพลังชีวิต

    public HealthBar playerhealthBar;

    public Vector3 playerVelocity;
    public bool groundedPlayer;
    [SerializeField] private float playerSpeed = 5f;
    [SerializeField] private Camera followCamera;
    [SerializeField] private float rotationSpeed = 10f;
    [SerializeField] private float gravityValue = -13f;
    [SerializeField] private float jumpHeight = 2.5f;
    
    public AudioSource weaponSwitchSound;  // ✅ เพิ่มตัวแปรสำหรับเสียงเปลี่ยนอาวุธ
    
    private void Start()
    {
        health = maxHealth;
        playerhealthBar.SetMaxHealth(maxHealth);
        
        controller = GetComponent<CharacterController>();
        animator = GetComponentInChildren<Animator>(); // ดึง Animator ของตัวละคร

        if (weapon != null)
        {
            weapon.SetActive(false);  // เริ่มต้นซ่อนอาวุธ
            RulerBladeController = weapon.GetComponent<Animator>();
        }

        if (weaponSwitchSound == null) // ตรวจสอบว่า AudioSource ถูกเชื่อมต่อหรือไม่
        {
            weaponSwitchSound = GetComponent<AudioSource>();  // ดึง AudioSource
        }
    }

    void Update()
    {
            // เช็คการกดปุ่ม 1 เพื่อ toggle การถืออาวุธ
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            // สลับสถานะ RulerBlade
            RulerBlade = !RulerBlade;

            // ตั้งค่าใน Animator
            animator.SetBool("RulerBlade", RulerBlade);

            // 🎮 เรียกฟังก์ชัน ShowSparkEffects เมื่อเปิดหรือปิด RulerBlade
            ShowSparkEffects();
        }
        if (weapon != null)
        {
            weapon.SetActive(RulerBlade);  // ถ้า RulerBlade เป็น true จะทำให้แสดงอาวุธ
        }

        // 🛠️ **กด R เพื่อเปลี่ยนรูปร่างอาวุธ**
        if (RulerBlade && Input.GetKeyDown(KeyCode.R))
        {
            StartCoroutine(SwitchWeaponMode());
        }

        Movement();
    }
    
    void ShowSparkEffects()
    {
        if (sparkEffects.Length == 0) return;

        foreach (GameObject effect in sparkEffects)
        {
            if (effect == null) continue;

            effect.SetActive(true);
            StartCoroutine(HideEffectAfterTime(effect, 0.7f)); // ⏳ ปิดเอฟเฟคหลัง 0.7 วิ
        }
    }
    // ฟังก์ชันสำหรับปิดเอฟเฟคหลังจากผ่านไปบางเวลา
    IEnumerator HideEffectAfterTime(GameObject effect, float delay)
    {
        yield return new WaitForSeconds(delay);
        effect.SetActive(false);
    }

    private IEnumerator SwitchWeaponMode()
    {
        // เล่นเสียงเปลี่ยนอาวุธ
        if (weaponSwitchSound != null)
        {
            weaponSwitchSound.Play();
        }
        // 🔥 เล่นอนิเมชั่นเปลี่ยนรูปร่างอาวุธ
        animator.SetTrigger("SwitchWeapon");
        if (RulerBladeController != null)
        {
            RulerBladeController.SetTrigger("SwitchWeapon");
        }

        // รอให้อนิเมชั่นเปลี่ยนรูปแบบอาวุธเล่นเสร็จ
        yield return new WaitForSeconds(1.5f); // 🔹 ปรับตามความยาวของอนิเมชั่น

        // 🔄 เปลี่ยนสถานะเป็นโหมดดาบใหญ่
        isGreatSwordMode = !isGreatSwordMode;

        // อัพเดต Blend Tree
        animator.SetBool("isGreatSwordMode", isGreatSwordMode);
    }

    public static PlayerController instance;

    private void Awake()
    {
        instance = this;
    }
    
    public bool isCharging { get; set; } = false; // เปลี่ยน set ให้เป็น public

    public void TakeDamage(float damage)
    {
        // 🛑 ป้องกันการรับดาเมจระหว่างชาร์จ
        if (isCharging)
        {
            Debug.Log("❌ กำลังชาร์จโจมตี → ไม่ได้รับดาเมจ!");
            animator.SetTrigger("ChargeBlock"); // 🎬 เล่นแอนิเมชันป้องกันระหว่างชาร์จ
            return;
        }

        health -= damage;
        playerhealthBar.SetHealth(health);

        Debug.Log("Player received damage: " + damage);
        Debug.Log("Current Health: " + health);

        // 🎬 เลือกอนิเมชันรับดาเมจตามโหมดอาวุธ
        if (isGreatSwordMode)
        {
            animator.SetTrigger("HitGreatSword"); // 🎬 เล่นอนิเมชันโดนตีของ GreatSword
        }
        else
        {
            animator.SetTrigger("HitRulerBlade"); // 🎬 เล่นอนิเมชันโดนตีของ RulerBlade
        }

        if (health <= 0)
        {
            Die(); 
        }
    }

    public bool isDead = false;
    public void Die()
    {
        // 🔴 ปิดการเคลื่อนไหวทั้งหมด
        canMove = false;
        controller.enabled = false; // ปิด CharacterController เพื่อป้องกันการขยับ
        animator.SetTrigger("Die"); // 🟢 เล่นแอนิเมชันตาย

        Debug.Log("Player died!");
        isDead = true; // 🟡 ตั้งค่าสถานะว่าตายแล้ว
    }

    // ✅ ฟังก์ชันเพิ่มเลือด
    public void Heal(float amount)
    {
        health += amount;
        if (health > maxHealth) health = maxHealth; // ห้ามเกิน max
        playerhealthBar.SetHealth(health); // อัปเดต UI Health Bar
    }

    // ✅ เอฟเฟคเพิ่มความเร็วชั่วคราว
    public IEnumerator SpeedBoost(float speedIncreasePercent, float duration)
    {
        float originalSpeed = playerSpeed;
        playerSpeed *= (1 + speedIncreasePercent / 100f); // เพิ่ม speed

        yield return new WaitForSeconds(duration); // ⏳ รอเวลาหมด
        playerSpeed = originalSpeed; // กลับสู่ปกติ
    }

    // ✅ เอฟเฟคเพิ่มพลังโจมตีชั่วคราว
    public IEnumerator AttackBoost(float attackIncreasePercent, float duration)
    {
        float originalMultiplier = movementSpeedMultiplier;
        movementSpeedMultiplier *= (1 + attackIncreasePercent / 100f); // เพิ่มพลังโจมตี

        yield return new WaitForSeconds(duration); // ⏳ รอเวลาหมด
        movementSpeedMultiplier = originalMultiplier; // กลับสู่ปกติ
    }

    void Movement()
    {
        groundedPlayer = controller.isGrounded;
        // ScriptPlayerController#4.1 PlayerJumpFix
        if (controller.isGrounded && playerVelocity.y < -2)
        {
            playerVelocity.y = -1f;
        }
        
        // ScriptPlayerController#1 PlayerMove
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");

        animator.SetFloat("Horizontal", horizontalInput);
        animator.SetFloat("Vertical", verticalInput);

        Vector3 movementInput = Quaternion.Euler(0, followCamera.transform.eulerAngles.y, 0)
                                * new Vector3(horizontalInput, 0, verticalInput);

        Vector3 movementDirection = movementInput.normalized;

        // ลดความเร็วเฉพาะเมื่อโจมตี
        if (isGreatSwordMode) // เมื่ออยู่ในโหมด Great Sword
        {
            movementSpeedMultiplier = 0.1f; // ลดความเร็วลงในระหว่างโจมตี
        }
        else
        {
            movementSpeedMultiplier = 1f; // กลับค่าความเร็วปกติ
        }

        if (!canMove) return; // ❌ หยุดการเคลื่อนที่ถ้า canMove เป็น false
        controller.Move(movementDirection * playerSpeed * movementSpeedMultiplier * Time.deltaTime);

        controller.Move(movementDirection * playerSpeed * Time.deltaTime);

        // ScriptPlayerController#2 PlayerRotation
        if (movementDirection.magnitude > 0) // ถ้ามีการเคลื่อนที่
        {
            Vector3 cameraForward = followCamera.transform.forward; // 🔴 เอาทิศทางของกล้อง
            cameraForward.y = 0; // 🔴 ไม่ให้หมุนแกน Y
            Quaternion desiredRotation = Quaternion.LookRotation(cameraForward); // 🔴 ให้ตัวละครหันไปตามกล้อง

            transform.rotation = Quaternion.Slerp(transform.rotation, desiredRotation, rotationSpeed * Time.deltaTime);
        }

        // ScriptPlayerController#4 PlayerJump
        if (Input.GetButtonDown("Jump") && groundedPlayer)
        {
            playerVelocity.y += Mathf.Sqrt(jumpHeight * -3.0f * gravityValue);
            animator.SetBool("isJumping", true);  // 🟡 เล่นอนิเมชัน Jumping
        }
        
        // 🟠 **ตรวจสอบว่าอยู่ในอากาศ (Falling)**
        if (!groundedPlayer && playerVelocity.y < 0)
        {
            animator.SetBool("isJumping", false);
            animator.SetBool("isFalling", true);  // 🟠 เล่น FallingIdle
        }

        // 🟢 **เมื่อลงถึงพื้นให้เล่น FallToStand**
        if (groundedPlayer && animator.GetBool("isFalling"))
        {
            animator.SetBool("isFalling", false);
            animator.Play("FallToStand");  // 🟢 เล่นอนิเมชันลงพื้น
        }

        // ScriptPlayerController#3 PlayerGravity
        playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);
    }

}
