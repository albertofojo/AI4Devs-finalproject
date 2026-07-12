"""Tests de autenticación y perfil (HU-01)."""


def test_me_requires_token(client):
    resp = client.get("/api/me")
    assert resp.status_code == 401


def test_me_rejects_bad_signature(client):
    resp = client.get("/api/me", headers={"Authorization": "Bearer not-a-jwt"})
    assert resp.status_code == 401


def test_me_creates_profile_on_first_call(client, alice):
    resp = client.get("/api/me", headers=alice)
    assert resp.status_code == 200
    body = resp.json()
    assert body["email"] == "alice@example.com"
    assert body["id"] == "11111111-1111-1111-1111-111111111111"


def test_update_profile(client, alice):
    client.get("/api/me", headers=alice)
    resp = client.put(
        "/api/me",
        headers=alice,
        json={"full_name": "Alice Wonder", "main_instrument": "violín", "level": "pro"},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["full_name"] == "Alice Wonder"
    assert body["level"] == "pro"


def test_update_profile_rejects_bad_level(client, alice):
    resp = client.put("/api/me", headers=alice, json={"level": "maestro"})
    assert resp.status_code == 422
