"""Test de integración del flujo principal E2E (HU-01 a HU-06).

Recorre: crear grupo → invitar → aceptar → subir partitura → crear setlist →
añadir partitura al setlist → programar ensayo con setlist → confirmar asistencia →
consultar el detalle del ensayo con su repertorio y resumen de asistencia.
"""


def test_full_mvp_flow(client, alice, bob):
    # 1) Alice (directora) crea el grupo → queda como admin
    group_id = client.post(
        "/api/groups",
        headers=alice,
        json={"name": "Banda Municipal", "type": "banda", "description": "viento y percusión"},
    ).json()["id"]

    # 2) Alice invita a Bob y Bob acepta
    token = client.post(
        f"/api/groups/{group_id}/invitations",
        headers=alice,
        json={"email": "bob@example.com"},
    ).json()["token"]
    assert client.post(f"/api/invitations/{token}/accept", headers=bob).status_code == 200

    # 3) Alice sube una partitura MusicXML
    score = client.post(
        f"/api/groups/{group_id}/scores",
        headers=alice,
        json={
            "title": "Marcha de Ejemplo",
            "composer": "Anónimo",
            "format": "musicxml",
            "file_url": "https://storage.example/scores/marcha.musicxml",
            "key_signature": "Bb",
        },
    )
    assert score.status_code == 201, score.text
    score_id = score.json()["id"]

    # Bob (miembro) ve la partitura del grupo
    scores = client.get(f"/api/groups/{group_id}/scores", headers=bob).json()
    assert len(scores) == 1 and scores[0]["id"] == score_id

    # 4) Alice crea un Setlist y le añade la partitura
    setlist_id = client.post(
        f"/api/groups/{group_id}/setlists",
        headers=alice,
        json={"name": "Concierto de Primavera"},
    ).json()["id"]
    add = client.post(
        f"/api/setlists/{setlist_id}/items",
        headers=alice,
        json={"score_id": score_id, "notes": "Repasar dinámicas"},
    )
    assert add.status_code == 201
    assert add.json()["items"][0]["score_id"] == score_id
    assert add.json()["items"][0]["position"] == 0

    # 5) Alice programa un ensayo asociando el Setlist
    rehearsal = client.post(
        f"/api/groups/{group_id}/rehearsals",
        headers=alice,
        json={
            "title": "Ensayo general",
            "location": "Auditorio Sala 2",
            "starts_at": "2026-08-10T18:00:00Z",
            "ends_at": "2026-08-10T20:00:00Z",
            "setlist_id": setlist_id,
        },
    )
    assert rehearsal.status_code == 201, rehearsal.text
    rehearsal_id = rehearsal.json()["id"]
    assert rehearsal.json()["setlist"]["name"] == "Concierto de Primavera"
    # 2 miembros, aún nadie ha respondido
    assert rehearsal.json()["attendance_summary"]["pending"] == 2

    # 6) Bob confirma asistencia
    att = client.put(
        f"/api/rehearsals/{rehearsal_id}/attendance",
        headers=bob,
        json={"status": "confirmed"},
    )
    assert att.status_code == 200
    assert att.json()["my_attendance"] == "confirmed"
    assert att.json()["attendance_summary"]["confirmed"] == 1
    assert att.json()["attendance_summary"]["pending"] == 1

    # 7) Bob abre el detalle del ensayo: ve el setlist y su partitura
    detail = client.get(f"/api/rehearsals/{rehearsal_id}", headers=bob).json()
    assert detail["setlist"]["items"][0]["score_id"] == score_id
    assert detail["my_attendance"] == "confirmed"


def test_list_setlists_and_rehearsals(client, alice):
    group_id = client.post(
        "/api/groups", headers=alice, json={"name": "G", "type": "banda"}
    ).json()["id"]
    client.post(
        f"/api/groups/{group_id}/setlists", headers=alice, json={"name": "S1"}
    )
    client.post(
        f"/api/groups/{group_id}/rehearsals",
        headers=alice,
        json={"title": "R1", "starts_at": "2026-08-10T18:00:00Z"},
    )
    setlists = client.get(f"/api/groups/{group_id}/setlists", headers=alice).json()
    rehearsals = client.get(f"/api/groups/{group_id}/rehearsals", headers=alice).json()
    assert len(setlists) == 1 and setlists[0]["name"] == "S1"
    assert len(rehearsals) == 1 and rehearsals[0]["title"] == "R1"


def test_outsider_cannot_access_group(client, alice, bob):
    group_id = client.post(
        "/api/groups", headers=alice, json={"name": "Privado", "type": "banda"}
    ).json()["id"]
    # bob no es miembro
    assert client.get(f"/api/groups/{group_id}", headers=bob).status_code == 403
    assert client.get(f"/api/groups/{group_id}/scores", headers=bob).status_code == 403


def test_attendance_update_is_idempotent(client, alice):
    group_id = client.post(
        "/api/groups", headers=alice, json={"name": "G", "type": "banda"}
    ).json()["id"]
    rid = client.post(
        f"/api/groups/{group_id}/rehearsals",
        headers=alice,
        json={"title": "E", "starts_at": "2026-08-10T18:00:00Z"},
    ).json()["id"]

    client.put(f"/api/rehearsals/{rid}/attendance", headers=alice, json={"status": "maybe"})
    final = client.put(
        f"/api/rehearsals/{rid}/attendance", headers=alice, json={"status": "confirmed"}
    ).json()
    assert final["attendance_summary"]["confirmed"] == 1
    assert final["attendance_summary"]["maybe"] == 0
