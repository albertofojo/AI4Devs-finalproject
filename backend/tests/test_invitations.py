"""Tests de invitaciones y control de roles (HU-02, HU-03)."""


def _create_group(client, headers) -> str:
    resp = client.post(
        "/api/groups", headers=headers, json={"name": "Banda Test", "type": "banda"}
    )
    assert resp.status_code == 201, resp.text
    return resp.json()["id"]


def test_create_group_makes_creator_admin(client, alice):
    resp = client.post(
        "/api/groups", headers=alice, json={"name": "Orquesta", "type": "orquesta"}
    )
    assert resp.status_code == 201
    assert resp.json()["my_role"] == "admin"


def test_non_admin_cannot_invite(client, alice, bob):
    group_id = _create_group(client, alice)
    # bob no pertenece al grupo → 403
    resp = client.post(
        f"/api/groups/{group_id}/invitations",
        headers=bob,
        json={"email": "carol@example.com"},
    )
    assert resp.status_code == 403


def test_invite_and_accept_flow(client, alice, bob):
    group_id = _create_group(client, alice)
    inv = client.post(
        f"/api/groups/{group_id}/invitations",
        headers=alice,
        json={"email": "bob@example.com"},
    )
    assert inv.status_code == 201, inv.text
    token = inv.json()["token"]

    accept = client.post(f"/api/invitations/{token}/accept", headers=bob)
    assert accept.status_code == 200
    assert accept.json()["status"] == "active"

    # bob ahora ve el grupo en su listado
    groups = client.get("/api/groups", headers=bob).json()
    assert any(g["id"] == group_id for g in groups)


def test_accept_twice_is_idempotent(client, alice, bob):
    group_id = _create_group(client, alice)
    token = client.post(
        f"/api/groups/{group_id}/invitations",
        headers=alice,
        json={"email": "bob@example.com"},
    ).json()["token"]

    client.post(f"/api/invitations/{token}/accept", headers=bob)
    second = client.post(f"/api/invitations/{token}/accept", headers=bob)
    assert second.status_code == 200  # idempotente, no duplica ni falla

    # solo una membresía activa de bob
    groups = [g for g in client.get("/api/groups", headers=bob).json() if g["id"] == group_id]
    assert len(groups) == 1


def test_accept_invalid_token(client, bob):
    resp = client.post("/api/invitations/token-inexistente/accept", headers=bob)
    assert resp.status_code == 404
