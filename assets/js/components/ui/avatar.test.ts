import { describe, expect, it } from "vitest";

import { buildAvatarModel, hashAvatarSeed } from "@/components/ui/avatar";

describe("hashAvatarSeed", () => {
  it("returns the same hash for the same seed", () => {
    expect(hashAvatarSeed("acme:john@example.com")).toBe(hashAvatarSeed("acme:john@example.com"));
  });

  it("returns different hashes for different seeds", () => {
    expect(hashAvatarSeed("acme:john@example.com")).not.toBe(
      hashAvatarSeed("acme:jane@example.com"),
    );
  });

  it("returns an unsigned integer", () => {
    const hash = hashAvatarSeed("template_app:test@example.com");

    expect(Number.isInteger(hash)).toBe(true);
    expect(hash).toBeGreaterThanOrEqual(0);
  });
});

describe("buildAvatarModel", () => {
  it("builds a stable model for the same seed", () => {
    expect(buildAvatarModel("acme:john@example.com")).toEqual(
      buildAvatarModel("acme:john@example.com"),
    );
  });

  it("builds visually distinct models for different seeds", () => {
    const first = buildAvatarModel("acme:john@example.com");
    const second = buildAvatarModel("acme:jane@example.com");

    expect(first.start).not.toBe(second.start);
    expect(first.end).not.toBe(second.end);
    expect(first.squares).not.toEqual(second.squares);
  });

  it("creates a dense ordered dither field", () => {
    const model = buildAvatarModel("acme:john@example.com");

    expect(model.squares.length).toBeGreaterThan(140);
    expect(model.squares.length).toBeLessThan(420);
  });

  it("falls back to an anonymous seed for blank input", () => {
    expect(buildAvatarModel("   ")).toEqual(buildAvatarModel("anonymous"));
  });
});
