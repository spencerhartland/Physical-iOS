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
1. Add `isOwned` property to `Media` to enable users to add media that they *want* but do not *own*.
    - Update `Media`.
    - Update `MediaDetailsEntryView`.
    - Update `MediaDetailView`.
    - Add "Own" and "Want" filters to `MediaCollectionView`.
2. Build a `User` model.
    - Persist with SwiftData.
    - Save to AWS and make available publicly.
3. Add `SocialProfileView`.
4. Add `SocialDashboardView`.
