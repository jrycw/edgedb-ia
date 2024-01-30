# 簡介
!!! quote "《涅槃經》第十九卷"
    八大地獄之最，稱為無間地獄，為無間斷遭受大苦之意，故有此名。

<figure markdown>
![index](https://m.media-amazon.com/images/M/MV5BZTU5ZDI2M2ItZTZlZS00YjU3LTg5MmEtNDIxNjc1NjM4MmVhXkEyXkFqcGdeQXVyNDE3OTAyNDU@._V1_FMjpg_UX600_.jpg){ loading=lazy }
  <figcaption><a href="https://www.imdb.com/title/tt0338564/mediaindex">此劇照引用自IMDb-無間道</a></figcaption>
</figure>

## 緣起
這個project的概念源自[Easy EdgeDB](https://www.edgedb.com/easy-edgedb)。書內用吸血鬼為主題，帶領讀者一步步跟著故事，使用EdgeDB來模擬，是一份相當好的學習資源。

在閱讀完`Easy EdgeDB`之後，因為太喜歡這種學習方式，所以我決定找一部我很喜歡的電影，[無間道系列第一集](https://zh.wikipedia.org/zh-tw/%E7%84%A1%E9%96%93%E9%81%93)，以類似的技巧來練習EdgeDB。

如果您在尋找EdgeDB的中文教材，相信這個project應該能帶給你些許收獲。

## 使用方式
!!! quote "佛曰"
    受身無間者永遠不死，壽長乃無間地獄中之大劫。

既名無間道，表示時間與空間都是模糊的。三部曲間，有相容亦有衝突，或許每一個分支都是一個平行時空。如若真的想深入了解，可以參考知乎網友所寫的[四十篇無間道系列劇情梳理](https://www.zhihu.com/column/c_183275144)。

這個project剛開始時，本來打算仿效`Easy EdgeDB`，使用一步步建構schema的方式來寫。但由於劇情過於複雜，如果全部順著故事線前進，只會陷入無止境的migration輪迴中。

所以最後決定先建立一個[初始schema](initial_schema/person/person.md)，裡面包含了基本的人時地事。

接著再從劇中選了十幕，於每幕中交待劇情，熟悉query寫法、逐步改進schema及進行migration。

[每一幕](scenes/scene01/scene01.md)的最上面都會有一個`Full schema preview`，裡面有每一次migration所使用的schema，並以顏色標注了該migration與前次的差異之處。每一幕的最下面則有一個`Query review`，裡面包含了該幕所有執行的query。

!!! success "EdgeDB is awesome!"
    期許您於閱讀完這個project後，可以一起利用EdgeDB讓世界變得更酷一點。




