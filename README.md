# Physical
Physical is a digital catalogue of your music on physical media. Build your catalogue by adding the vinyl records, CDs, and cassettes you already own with help from Apple Music to fill in all the details. Plan new additions by adding the music you want and add new finds on the fly by scanning an item's barcode.

Physical also helps you share and discover new music with social features that allow you to browse friends' collections and post your favorite tracks or albums. This is social media designed for music lovers.

[Learn more](http://spencerhartland.com/physical.html)

## Technologies and frameworks
- SwiftData
- AWS (S3, DynamoDB, API Gateway, Lambda)
- MusicKit
- SwiftUI
- UIKit

## To-do
This is really just a to-do list for myself, but should provide an idea of where Physical is at in development.
1. Build `SocialView`.
- Use social post views and build a simple list-based UI.
- Add stories-like "Daily Picks" at the top.
2. Determine API calls needed for `SocialView` and `SocialProfileView`.
3. Create table in DynamoDB based on API calls.
4. Build APIs in Lambda.
- First, post log-in flow (profile creation, show social views).
- After that, work on posting simple posts.
