import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || "https://omniroute.local";
  return {
    rules: [
      {
        userAgent: "*",
        allow: ["/", "/privacy", "/terms", "/docs", "/status"],
        disallow: ["/api/", "/dashboard/", "/miniapp/", "/auth/", "/connect/"],
      },
    ],
    sitemap: `${baseUrl}/sitemap.xml`,
  };
}
