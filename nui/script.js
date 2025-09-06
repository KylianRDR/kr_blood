let currentBodyParts = {};
let currentPlayerName = '';

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openMedicalExam') {
        currentBodyParts = data.bodyParts;
        currentPlayerName = data.playerName;
        
        document.getElementById('patientName').textContent = `Patient: ${currentPlayerName}`;
        updateBodyDiagram();
        updateBodyInfo();
        
        document.getElementById('medicalExam').style.display = 'block';
    }
});

function updateBodyDiagram() {
    const bodyParts = document.querySelectorAll('.body-part');
    
    bodyParts.forEach(part => {
        const partName = part.getAttribute('data-part');
        const partData = currentBodyParts[partName];
        
        if (partData) {
            const healthPercent = partData.health;
            
            part.classList.remove('damaged', 'critical');
            
            if (healthPercent <= 0) {
                part.classList.add('critical');
            } else if (healthPercent < 70) {
                part.classList.add('damaged');
            }
        }
    });
}

function updateBodyInfo() {
    const allWeapons = new Set();
    
    Object.keys(currentBodyParts).forEach(partName => {
        const partData = currentBodyParts[partName];
        const partElement = document.getElementById(partName);
        
        if (partElement && partData) {
            const healthPercent = partData.health;
            const healthFill = partElement.querySelector('.health-fill');
            const healthPercentText = partElement.querySelector('.health-percent');
            const weaponsContainer = partElement.querySelector('.weapons-used');
            
            healthFill.style.width = healthPercent + '%';
            healthPercentText.textContent = Math.round(healthPercent) + '%';
            
            healthFill.classList.remove('damaged', 'critical');
            if (healthPercent <= 0) {
                healthFill.classList.add('critical');
            } else if (healthPercent < 70) {
                healthFill.classList.add('damaged');
            }
            
            weaponsContainer.innerHTML = '';
            if (partData.weapons && partData.weapons.length > 0) {
                partData.weapons.forEach(weapon => {
                    allWeapons.add(weapon);
                    const weaponTag = document.createElement('span');
                    weaponTag.className = 'weapon-tag';
                    weaponTag.textContent = weapon;
                    weaponsContainer.appendChild(weaponTag);
                });
            }
        }
    });
    
    const weaponList = document.getElementById('weaponList');
    if (allWeapons.size > 0) {
        weaponList.textContent = Array.from(allWeapons).join(', ');
    } else {
        weaponList.textContent = 'Aucune blessure par arme détectée';
    }
}

document.querySelectorAll('.body-part').forEach(part => {
    part.addEventListener('mouseenter', function() {
        const partName = this.getAttribute('data-part');
        const partData = currentBodyParts[partName];
        
        if (partData && partData.weapons.length > 0) {
            const weaponList = document.getElementById('weaponList');
            weaponList.textContent = `Zone: ${getPartDisplayName(partName)} - Armes: ${partData.weapons.join(', ')}`;
        }
    });
    
    part.addEventListener('mouseleave', function() {
        updateBodyInfo();
    });
});

function getPartDisplayName(partName) {
    const displayNames = {
        'tete': 'Tête',
        'torse': 'Torse',
        'estomac': 'Estomac',
        'bras_gauche': 'Bras Gauche',
        'bras_droit': 'Bras Droit',
        'jambe_gauche': 'Jambe Gauche',
        'jambe_droite': 'Jambe Droite'
    };
    return displayNames[partName] || partName;
}

function closeMedicalExam() {
    document.getElementById('medicalExam').style.display = 'none';
    
    fetch(`https://${GetParentResourceName()}/closeMedicalExam`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMedicalExam();
    }
});