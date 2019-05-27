# DoIKnowYou (Enhanced) for The Burning Crusade

This is an enhanced, bugfixed version of **DoIKnowYou** for The Burning Crusade! (TBC 2.4.3)

**Enhancements:**

- Now shows author names for shared notes. This makes it very easy to see who wrote each comment, which helps you decide whether you trust that opinion or not. Especially useful in large guilds where lots of people use this addon! [Details.](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/commit/4eb577191c1a0c297108d6cd09ed07691e9971c7)
- The player tooltips can now display notes written by trusted people _if you haven't created any personal note_. This shows up a bit differently than your own notes; ie. as _"Yourtrustedfriend says: This guy is a real jerk!"_. Extremely convenient, since it now means that you don't have to manually write notes for everyone you see (whenever good and trusted opinions already exist). And you're _still able_ to write personal notes _if you want to_, which of course takes precedence over any shared notes! [Details.](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/commit/153e2867368f0bde218f2eaf2baf1b83ab5d43bc)
- Better default behavior for displaying reputation and notes for "Neutral" players, to ensure that available notes are always shown even when people have a neutral rating. [Details.](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/commit/e7a8ba6e9b2eff22b5763258fb5337dac98d27df)
- Automatically cleans up useless whitespace around your notes (and received/shared notes). [Details.](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/commit/2fe6c333751467b5339cdc6cffe974d174899171)

**Fixed Bugs:**

- You will no longer get disconnected whenever the addon attempts to sync lots of data. [Details.](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/commit/c4eebb1fc4347397152fe8a94c2f0213d2a9d011)
- The addon is now capable of syncing long player notes/comments. (The official version always lost tons of data whenever it attempted to sync long notes.) [Details.](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/commit/c4eebb1fc4347397152fe8a94c2f0213d2a9d011)
- No more Lua errors if you log into a guildless player or leave a guild. [Details.](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/commit/3a08a4c4a352280e8568d28342a9c1d464da554a)

**Download: [DoIKnowYouEnhancedTBC-master.zip](https://github.com/VideoPlayerCode/DoIKnowYouEnhancedTBC/archive/master.zip)** (Put the inner "DoIKnowYou" folder into your WoW's "Interface/AddOns" folder.)

