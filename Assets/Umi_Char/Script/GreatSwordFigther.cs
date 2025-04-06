using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class GreatSwordFighter : MonoBehaviour
{
    private Animator animator;
    private PlayerController playerController; // ✅ อ้างอิงไปที่ PlayerController

    public float cooldownTime = 2f;
    private float nextFireTime = 0f;
    public static int noOfClicks = 0;

    public SkillBar skillhbar;  // ✅ เชื่อม Energy Bar
    float lastClickedTime = 0;
    float maxComboDelay = 1;

    public GameObject[] slashEffects; // เก็บเอฟเฟคหลายแบบ
    public GameObject[] hitboxSlashes; // ✅ เพิ่ม hitbox แต่ละคอมโบ
    public GameObject[] chargeEffects; // ✅ เอฟเฟคชาร์จ (แยกจาก SlashEffect)
    public GameObject chargeAttackEffect; // ✅ เอฟเฟคเฉพาะของ Charge Attack
    public GameObject chargeAttackHitbox; // ✅ Hitbox ของ Charge Attack

    public bool isCharging = false; // ✅ กำลังชาร์จอยู่ไหม
    public float chargeStartTime = 0f;
    public float maxChargeTime = 3f; // ✅ ชาร์จได้สูงสุด 3 วินาที
    
    public float maxChargeCooldown = 5f; // ✅ คูลดาวน์หลังจากใช้ Charge Attack
    private float chargeCooldown = 0f; // ✅ เวลาคูลดาวน์ที่เหลืออยู่
    public float chargeCooldownCount = 5f;

    private void Start()
    {
        animator = GetComponentInChildren<Animator>(); // ดึง Animator ของตัวละคร
        playerController = GetComponent<PlayerController>(); // ✅ ดึง PlayerController

        if (skillhbar != null)
            skillhbar.SetMaxSkill(maxChargeCooldown);  // ✅ ตั้งค่า Energy Bar เต็ม
        else
            Debug.LogError("❌ SkillBar ยังไม่ได้เชื่อมต่อ! กรุณาเซ็ตใน Inspector");
    }

    void Update()
    {
        // ✅ ใช้โค้ดนี้ต่อเมื่อ "อยู่ในโหมด Great Sword"
        if (playerController == null || !playerController.RulerBlade || !playerController.isGreatSwordMode) 
        {
            return;
        }

        // ✅ ห้ามกดโจมตีถ้ากำลังเปลี่ยนอาวุธอยู่
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("ChangetoRulerBlade")) 
        {
            return;
        }

        // ✅ ห้ามเคลื่อนที่ถ้ากำลังชาร์จ
        if (isCharging || animator.GetCurrentAnimatorStateInfo(0).IsName("GS_Charge"))
        {
            playerController.canMove = false;
            playerController.movementSpeedMultiplier = 0f;
            Debug.Log("ชาร์จห้ามเดินทำงาน");

            // ห้ามโจมตีขณะชาร์จ
            if (Input.GetMouseButtonDown(0)) // ถ้ากดคลิกซ้ายขณะชาร์จ
            {
                return;  // ไม่ให้ทำการโจมตี
            }
        }
        else
        {
            playerController.canMove = true;
            playerController.movementSpeedMultiplier = 1f;
            Debug.Log("ไม่ชาร์จเดินทำงาน");
        }

        // ✅ ตรวจจับการปล่อยเมาส์ขวา หรือชาร์จเต็ม 3 วิ
        if (isCharging && (Input.GetMouseButtonUp(1) || Time.time - chargeStartTime >= maxChargeTime))
        {
            ReleaseChargeAttack();
        }

        if (chargeCooldown > 0)
        {
            chargeCooldown -= Time.deltaTime;
        }

        if (Time.time - lastClickedTime > maxComboDelay)
        {
            noOfClicks = 0;
        }
        
        if (Time.time > nextFireTime)
        {
            if (Input.GetMouseButtonDown(0))
            {
                OnClick();
            }

            // ✅ เริ่มต้นชาร์จเมื่อกดเมาส์ขวา
            if (Input.GetMouseButtonDown(1) && chargeCooldown <= 0)
            {
                StartChargeAttack();
            }
        }

        // ✅ เช็คว่ากำลังอยู่ในท่าไหน
        bool isGSFirstCombo = animator.GetCurrentAnimatorStateInfo(0).IsName("GSFirstCombo");
        bool isGSSecondCombo = animator.GetCurrentAnimatorStateInfo(0).IsName("GSSecondCombo");
        bool isGSThirdCombo = animator.GetCurrentAnimatorStateInfo(0).IsName("GSThirdCombo");

        if (isGSFirstCombo)
        {
            playerController.canMove = false;
        }
        else if (isGSSecondCombo || isGSThirdCombo)
        {
            playerController.movementSpeedMultiplier = 0.1f;  // 🐢 ลดความเร็ว 50%
        }
        else
        {
            playerController.movementSpeedMultiplier = 1f;  // 🔄 คืนค่าความเร็วปกติ
        }
        

        // ✅ ทำงานเฉพาะเมื่ออยู่ใน Great Sword
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("GSFirstCombo"))
        {
            animator.SetBool("hit1", false);
        }
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("GSSecondCombo"))
        {
            animator.SetBool("hit2", false);
        }
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("GSThirdCombo"))
        {
            animator.SetBool("hit3", false);
            noOfClicks = 0;
        }

        if (Time.time - lastClickedTime > maxComboDelay)
        {
            noOfClicks = 0;
        }

        // ✅ cooldown time
        if (Time.time > nextFireTime)
        {
            // ✅ Check for mouse input
            if (Input.GetMouseButtonDown(0))
            {
                OnClick();
            }
        }
    }

    void StartChargeAttack()
    {
        if (isCharging) return;

        isCharging = true;
        playerController.isCharging = true;  // ✅ อัปเดตค่า isCharging ใน PlayerController
        playerController.canMove = false; 
        playerController.movementSpeedMultiplier = 0f;

        chargeStartTime = Time.time;
        animator.SetBool("isCharging", true);

        StartCoroutine(ChargeEffectSequence()); 

        Debug.Log("เริ่มชาร์จโจมตี");
    }

    void ReleaseChargeAttack()
    {
        if (!isCharging) return;

        isCharging = false;
        playerController.isCharging = false;  // ✅ รีเซ็ตค่าเมื่อจบการชาร์จ
        playerController.canMove = false;
        playerController.movementSpeedMultiplier = 0f;

        animator.SetBool("isCharging", false);
        animator.SetTrigger("heavyAttack");

        ShowChargeAttackEffect();

        chargeCooldown = maxChargeCooldown; // ✅ ตั้งค่าคูลดาวน์ 5 วิ

        StopCoroutine(ChargeEffectSequence());

        Debug.Log("ปล่อยโจมตีหนัก!");

        StartCoroutine(ResetToBlendTree());

        chargeCooldownCount = 0; // ✅ หลอดลดลงหมดทันที
        skillhbar.SetSkill(chargeCooldownCount);
        StartCoroutine(IncreaseSkillBar());
    }

    IEnumerator IncreaseSkillBar()
    {
        float duration = maxChargeCooldown; // ✅ ระยะเวลา 5 วิ
        float timePassed = 0;

        while (timePassed < duration)
        {
            chargeCooldownCount = Mathf.Lerp(0, maxChargeCooldown, timePassed / duration); // ✅ ค่อย ๆ เพิ่ม cooldown
            skillhbar.SetSkill(chargeCooldownCount); // ✅ อัพเดตค่าหลอด

            timePassed += Time.deltaTime;
            yield return null; // ✅ รอเฟรมถัดไป
        }

        chargeCooldownCount = maxChargeCooldown; // ✅ สุดท้ายให้เซ็ต cooldown เป็นค่าตั้งต้น
        skillhbar.SetSkill(chargeCooldownCount); // ✅ อัพเดต UI
    }

    IEnumerator ResetToBlendTree()
    {
        yield return new WaitForSeconds(1.2f); // ✅ รอให้อนิเมชั่นเล่นจบ
        animator.SetTrigger("returnToIdle");

        playerController.canMove = true;  // ✅ คืนค่าหลังอนิเมชั่นจบ
        playerController.movementSpeedMultiplier = 1f;

        Debug.Log("กลับเข้าสู่ BlendTree");
    }

    public int chargeLevel = 0; // 🌟 เก็บระดับการชาร์จ

    IEnumerator ChargeEffectSequence()
    {
        chargeLevel = 0; // เริ่มต้นที่ระดับ 0
        for (int i = 0; i < 3; i++)
        {
            if (!isCharging) yield break;

            chargeLevel = i + 1; // อัปเดตระดับชาร์จ (เริ่มที่ 1)
            Debug.Log("Charge Level: " + chargeLevel);

            ShowChargeEffect(i);
            yield return new WaitForSeconds(1f);
        }
    }


    void ShowChargeEffect(int effectIndex)
    {
        if (chargeEffects.Length == 0) return; // ✅ กันพลาดไม่มีเอฟเฟค

        int index = Mathf.Clamp(effectIndex, 0, chargeEffects.Length - 1);
        GameObject effect = chargeEffects[index]; 

        effect.SetActive(true);
        StartCoroutine(HideEffectAfterTime(effect, 0.5f)); // ✅ ปิดเอฟเฟคหลัง 0.5 วิ

        Debug.Log($"แสดง Charge Effect: {index}");
    }

    void ShowChargeAttackEffect()
    {
        if (chargeAttackEffect == null) return; // ✅ ป้องกันข้อผิดพลาด
        if (chargeAttackHitbox == null) return;

        Invoke(nameof(ActivateChargeAttackEffect), 0.8f); // ✅ ดีเลย์ 2 วิ
    }

    void ActivateChargeAttackEffect()
    {
        chargeAttackEffect.SetActive(true);
        chargeAttackHitbox.SetActive(true);

        StartCoroutine(HideEffectAfterTime(chargeAttackEffect, 1f)); // ✅ ปิดเอฟเฟคหลัง 1 วิ
        StartCoroutine(HideEffectAfterTime(chargeAttackHitbox, 0.3f)); // ✅ ปิด Hitbox หลัง 0.3 วิ
    }
    
    void ShowSlashEffect(int hitIndex)
    {
        if (slashEffects.Length == 0) return;

        int effectIndex = Mathf.Clamp(hitIndex, 0, slashEffects.Length - 1);
        int hitboxIndex = Mathf.Clamp(hitIndex, 0, hitboxSlashes.Length - 1);

        GameObject effect = slashEffects[effectIndex];
        GameObject hitbox = hitboxSlashes[hitboxIndex]; // ✅ ใช้ hitbox ของคอมโบนี้


        // เปิดใช้งานเอฟเฟค
        effect.SetActive(true);
        hitbox.SetActive(true); // ✅ เปิดใช้งาน Hitbox พร้อมกับ Slash Effect

        // ปิดเอฟเฟคหลังจากเล่นเสร็จ (เช่น 0.5 วินาที)
        StartCoroutine(HideEffectAfterTime(effect, 0.5f));
        StartCoroutine(HideEffectAfterTime(hitbox, 0.2f)); // ✅ ปิด Hitbox เร็วกว่าหน่อย
    }

    IEnumerator HideEffectAfterTime(GameObject obj, float delay)
    {
        yield return new WaitForSeconds(delay);
        obj.SetActive(false);
    }
 
    void OnClick()
    {
        lastClickedTime = Time.time;
        noOfClicks++;
        if (noOfClicks == 1)
        {
            animator.SetBool("hit1", true);
            Invoke("ShowSlashEffect_0", 0.8f); // ✅ แสดง Slash Effect 0 หลังจาก 0.5 วินาที
        }
        noOfClicks = Mathf.Clamp(noOfClicks, 0, 3);

        if (noOfClicks >= 2 && animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("GSFirstCombo"))
        {
            animator.SetBool("hit1", false);
            animator.SetBool("hit2", true);
            Invoke("ShowSlashEffect_1", 0.8f); // ✅ แสดง Slash Effect 1 หลังจาก 0.5 วินาที
        }
        if (noOfClicks >= 3 && animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && animator.GetCurrentAnimatorStateInfo(0).IsName("GSSecondCombo"))
        {
            animator.SetBool("hit2", false);
            animator.SetBool("hit3", true);
            Invoke("ShowSlashEffect_2", 0.9f); // ✅ แสดง Slash Effect 2 หลังจาก 0.5 วินาที
        }
    }
    // ✅ ฟังก์ชันสำหรับเรียกใช้ Effect แยกตามลำดับ
        void ShowSlashEffect_0() { ShowSlashEffect(0); }
        void ShowSlashEffect_1() { ShowSlashEffect(1); }
        void ShowSlashEffect_2() { ShowSlashEffect(2); }
}
