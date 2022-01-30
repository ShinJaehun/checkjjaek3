class BooksController < ApplicationController
  before_action :set_book, only: [:show]
  before_action :authenticate_user!
  load_and_authorize_resource

  def show
    @posts = Post.where(postable_id: @book.id, postable_type: "Book").order(created_at: :desc)
  end

  def book_search

    # keyword_book으로 검색한 경우(책 검색 결과에 포스팅하기)
    if params.has_key?(:keyword_book)
      @keyword_book = params[:keyword_book]

      # 검색어가 있다면...
      if @keyword_book.present?

        @size = 50 # 한 화면에 표시할 검색 결과의 수

        if params[:page].to_s.empty?
          # 시작 위치가 정해져 있지 않으면 기본적으로 첫 페이지 보여주기
          @current_page = 1
        else

          # 시작 위치가 설정되어 있으면 해당 페이지로
          @current_page = params[:page].to_i

        end

        # url = "https://dapi.kakao.com/v2/search/book?query=" + @keyword_book + "&size=" + @size.to_s + "&page=" + @current_page.to_s 
        # url = "https://dapi.kakao.com/v2/search/book?target=title&query=" + @keyword_book + "&size=" + @size.to_s + "&page=" + @current_page.to_s 
        url = "https://dapi.kakao.com/v3/search/book?target=title&query=" + @keyword_book + "&size=" + @size.to_s + "&page=" + @current_page.to_s

        uri = URI.encode(url)
        res = RestClient.get(uri, headers={
          'Authorization' => Rails.application.credentials.kakao[:authorization_key]})
        unitokor = eval(res)
        json_g = JSON.generate(unitokor)
        hash = JSON.parse(json_g)

        # API의 total_count 값은 믿을 수 없음
        # 대신 pageable_count를 사용함(근데 이 값도 자꾸 변함)
        # @total_count = hash['meta']['total_count']
        @total_count = hash['meta']['pageable_count']

        # 마지막 페이지임을 알려주기 위해서 필요
        @is_end = hash['meta']['is_end'].to_s

#        puts "############################################################"
#        puts "total_count : " + @total_count.to_s

#        puts hash['meta']['pageable_count']
#        puts "마지막 페이지인가요: " + hash['meta']['is_end'].to_s
#        puts "현재 페이지 : " + @current_page.to_s + " 출력 건수 : " + @size.to_s + "  page * size : " + (@current_page * @size).to_s

        # 마지막 페이지
        @max_index = @total_count / @size + 1

        # 삼국지처럼 처음 검색했을 때는 pageable_count가 970에서
        # 마지막 페이지를 클릭하면 갑자기 483이 되는 경우
        if @max_index < @current_page
          @current_page = @max_index
        end

        # start_index와 end_index 값 지정하기
        if @current_page > 2
          @start_index = @current_page - 2
          if @current_page < @max_index - 2
            @end_index = @current_page + 2
          else
            @end_index = @max_index
          end
        else
          @start_index = 1
          if @max_index <= 5
            @end_index = @max_index
          else
            @end_index = 5
          end
        end

#        puts "current_page : " + @current_page.to_s + " max_index : " + @max_index.to_s
#        puts "start_index : " + @start_index.to_s + " end_index : " + @end_index.to_s 
#        puts "############################################################"

        @items = hash['documents']

      end
    end

    # 검색어가 없으면 items에 빈 array 넘기기
    @items ||= []

    @book = Book.new
    @book.posts.new
  end

  def new
  end

  def create
    unless @book = Book.find_by(isbn: book_params[:isbn])

      thumbnail_url = book_params[:thumbnail]

      # puts "thumbnail_url : " + thumbnail_url
      unless thumbnail_url.to_s.empty?
        # thumbnail_path = URI.unescape(thumbnail_url.match(/^http.+?(http.+?)%3F/)[1].to_s)
        # %3F는 '?'를 의미

        # puts "-----------------book_thumbnail-------------------------"
        thumbnail_url_unescape = URI.unescape(thumbnail_url)
        # puts "thumbnail_url_unescape : " + thumbnail_url_unescape

        # thumbnail_url_unescape_regex = thumbnail_url_unescape.match(/^http.+?(http.+?)\?/)[1].to_s
        # puts "thumbnail_url_unescape.nil? : " + (thumbnail_url_unescape.nil?).to_s
        # puts "thumbnail_url_unescape_regex.nil? : " + (thumbnail_url_unescape.match(/^http.+?(http.+?)\?/).nil?).to_s

        if !(thumbnail_url_unescape.match(/^http.+?(http.+?)\?/).nil?)
        # https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http://t1.daumcdn.net/lbook/image/1097174?timestamp=20210114144331
        # fname= 이후의 http://부터 ?timestamp 전까지 추출
          thumbnail_path = thumbnail_url_unescape.match(/^http.+?(http.+?)\?/)[1].to_s
        elsif !(thumbnail_url_unescape.match(/^http.+?(http.+?)$/).nil?)
        # https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http://t1.daumcdn.net/lbook/image/3744671
        # 뒤에 timestamp가 붙지 않는 녀석도 있음...  이나중 탁구부;;
          thumbnail_path = thumbnail_url_unescape.match(/^http.+?(http.+?)$/)[1].to_s
        else
          puts "큰일났어... 또 새로운 녀석이 나타났나봐...ㅠㅠ"
          thumbnail_path = nil
        end

        # puts "thumbnail_path : " + thumbnail_path
        # puts "-----------------book_thumbnail-------------------------"

      end

      @book = Book.create(
        title: CGI.unescapeHTML(book_params[:title]),
        contents: CGI.unescapeHTML(book_params[:contents]),
        url: book_params[:url],
        isbn:  book_params[:isbn],
        datetime: book_params[:datetime],
        authors: book_params[:authors],
        publisher: book_params[:publisher],
        translators: book_params[:transaltors],
        thumbnail:  thumbnail_path
      )
    end

#    puts "-----------------------book_params-----------------------"
#    puts book_params
#    puts "-----------------------book_params-----------------------"
#
#    puts "-----------------------book_params[:posts_attributes]-----------------------"
#    puts book_params[:posts_attributes]
#    puts "-----------------------book_params[:posts_attributes]-----------------------"
#
#    puts "-----------------------book_params[:posts_attributes]['0']-----------------------"
#    puts book_params[:posts_attributes]['0']
#    puts "-----------------------book_params[:posts_attributes]['0']-----------------------"

    r_id = params[:receiverrr_id].to_i

    post = @book.posts.new(content: book_params[:posts_attributes]['0'][:content])
    post.post_recipient_type = book_params[:posts_attributes]['0'][:post_recipient_type]
    post.user_id = current_user.id
    post.save

    if post.post_recipient_type == "User"
      post_recipient_user = PostRecipientUser.new
      post_recipient_user.post_id = post.id
      post_recipient_user.recipient_user_id = r_id
      post_recipient_user.save

      if r_id == current_user.id
        redirect_to root_path, flash: { notice: "책짹!" }
      else
        redirect_to user_path(r_id), flash: { notice: "책짹!" }
      end
    elsif post.post_recipient_type == "Group"
      if current_user.has_role? :group_member, Group.find(r_id)
        post_recipient_group = PostRecipientGroup.new
        post_recipient_group.post_id = post.id
        post_recipient_group.recipient_group_id = r_id
        post_recipient_group.save

        redirect_to group_path(r_id), flash: { notice: "책짹!" }
      else
        post.postable.destroy
        #이게 없으면 post 작성 실패할 때 message는 생성된 채로 남아 있음
        redirect_to group_path(r_id), flash: { alert: "group_member가 아니라서 그룹에 책짹을 작성할 권한 없음!" }
      end
    else
      redirect_to root_path, flash: { alert: "사용자에게 남기는 book 인데 prt이 User가 아님" }
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    # params.require(:book).permit(:title, :isbn, :authors, :thumbnail, :publisher, :contents, :url, :date_time, :translators, posts_attributes: [:user_id, :content])
    params.require(:book).permit(:title, :contents, :url, :isbn, :datetime, :authors, :publisher, :translators, :thumbnail, posts_attributes: [:content, :post_recipient_type])
  end

end
