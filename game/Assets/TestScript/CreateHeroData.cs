using JumpCSV;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateHeroData : MonoBehaviour {

	// Use this for initialization
	void Start () {
		GameData.Instance.CreateHero(ERId.HERO_SK);
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
