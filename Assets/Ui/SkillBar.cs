using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SkillBar : MonoBehaviour
{

	public Slider slider;
	public Image fill;

	public void SetMaxSkill(float gauge)
	{
		slider.maxValue = gauge;
		slider.value = gauge;
	}

    public void SetSkill(float gauge)
	{
		slider.value = gauge;
	}
}
